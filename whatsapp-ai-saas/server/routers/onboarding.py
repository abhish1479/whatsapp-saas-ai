# server/routers/onboarding.py
import random
from fastapi import APIRouter, BackgroundTasks, UploadFile, File, Form, HTTPException, Depends ,status
from fastapi.responses import JSONResponse
from typing import Optional, List, Literal
from requests import Session
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
import csv, io, json
from deps import get_db , SessionLocal
from services.rag import add_catalog_to_rag, rag
from models import AgentConfiguration, BusinessCatalog, BusinessProfile , Item, KnowledgeSource, Kyc , Payment, Template, Tenant, User, WebIngestRequest, Workflow
from data_models.onboarding_response_model import AgentConfigurationBase, ReviewResponse ,AgentConfigurationResponse, StatusResponse
from data_models.request_model import BusinessTypeRequest
from utils.enums import Onboarding
import re
import models


from workers.ingest_worker import background_crawl

router = APIRouter(prefix="/onboarding", tags=["onboarding"])

# --------------------------------------------------------------------
# constant regex: exactly 10 numeric digits (no +, spaces, or symbols)
# --------------------------------------------------------------------
TEN_DIGIT_PHONE_REGEX = re.compile(r'^[0-9]{10}$')

# ---------- STEP 1: Business Profile ----------
@router.post("/business")
def upsert_business_profile(
    business_name: str = Form(...),
    personal_number: str = Form(...),              # NEW
    business_whatsapp: str = Form(...),            # CHANGED (was owner_phone)
    tenant_id: int = Form(...),
    language: str = Form("en"),                    # keep to preserve preview/compat
    db: Session = Depends(get_db),
):
    # === Empty field validation ===
    if tenant_id is None:
        raise HTTPException(status_code=400, detail="Tenant ID cannot be empty.")
    if not business_name or not business_name.strip():
        raise HTTPException(status_code=400, detail="Business name cannot be empty.")
    if not personal_number or not personal_number.strip():
        raise HTTPException(status_code=400, detail="Personal number cannot be empty.")
    if not business_whatsapp or not business_whatsapp.strip():
        raise HTTPException(status_code=400, detail="Business WhatsApp number cannot be empty.")

    # === 10-digit number validation ===
    if not TEN_DIGIT_PHONE_REGEX.match(personal_number.strip()):
        raise HTTPException(
            status_code=400,
            detail="Personal number must be exactly 10 digits (no country code or symbols)."
        )
    if not TEN_DIGIT_PHONE_REGEX.match(business_whatsapp.strip()):
        raise HTTPException(
            status_code=400,
            detail="Business WhatsApp number must be exactly 10 digits (no country code or symbols)."
        )

    existing_profile = db.query(BusinessProfile).filter(
        BusinessProfile.tenant_id == tenant_id
    ).first()

    if existing_profile:
        existing_profile.business_name = business_name
        existing_profile.personal_number = personal_number
        existing_profile.business_whatsapp = business_whatsapp
        # keep existing_profile.language as-is (or set to language if desired)
        db.commit()
        return {
            "ok": True,
            "message": "Business profile updated successfully",
            "tenant_id": existing_profile.tenant_id,
        }

    business_profile = BusinessProfile(
        tenant_id=tenant_id,
        business_name=business_name,
        personal_number=personal_number,
        business_whatsapp=business_whatsapp,
        language=language,
    )
    db.add(business_profile)
    db.commit()
    return {
        "ok": True,
        "message": "Business profile created successfully",
        "tenant_id": tenant_id,
    }

# ---------- STEP 2: Business Type ----------
@router.post("/type")
def update_business_type(
    req: BusinessTypeRequest,          # ✅ Request body validation (Pydantic)
    db: Session = Depends(get_db)
):
    """
    Handles submission of business type information for a tenant.
    This step updates the business_profiles table with business_type,
    description, and (if applicable) custom fields for 'other' type.
    """

    # --- VALIDATION 1: Tenant must exist ---
    tenant = db.query(models.Tenant).filter(models.Tenant.id == req.tenant_id).first()
    if not tenant:
        raise HTTPException(status_code=400, detail=f"Tenant {req.tenant_id} not found")

    # --- VALIDATION 2: Business profile must exist ---
    profile = db.query(models.BusinessProfile).filter(
        models.BusinessProfile.tenant_id == req.tenant_id
    ).first()
    if not profile:
        raise HTTPException(status_code=404, detail="Business profile not found")

    # --- VALIDATION 3: business_type must be one of the allowed categories ---
    allowed_types = ["products", "services", "professional", "other"]
    if req.business_type.lower() not in allowed_types:
        raise HTTPException(
            status_code=400,
            detail=f"Invalid business_type. Allowed: {', '.join(allowed_types)}"
        )

    # --- VALIDATION 4: For 'other', require custom type field ---
    if req.business_type.lower() == "other" and not req.custom_business_type:
        raise HTTPException(
            status_code=400,
            detail="custom_business_type is required for 'other' type"
        )

    # --- PERFORM UPDATE ---
    profile.business_type = req.business_type
    profile.description = req.description
    profile.custom_business_type = req.custom_business_type
    profile.business_category = req.business_category
    db.commit()
    db.refresh(profile)

    # --- RETURN STRUCTURED RESPONSE (no response_model required) ---
    return {
        "status": "success",
        "message": "Business type updated successfully",
        "tenant_id": req.tenant_id,
        "data": {
            "business_type": profile.business_type,
            "description": profile.description,
            "custom_business_type": profile.custom_business_type,
            "business_category": profile.business_category,
        },
    }

# ---------- STEP 3a: Items via CSV (products/services) ----------
@router.post("/items/csv")
async def upload_items_csv(
    tenant_id: int = Form(...),
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    
    result =  db.execute(
        text("SELECT tenant_id FROM business_profiles WHERE tenant_id = :tenant_id"),
        {"tenant_id": tenant_id}
    )
    existing = result.fetchone()

    if existing is None:
        return {
            "ok": False,
            "message": "Business profile with this tenant id not found",
        }
    
    content = (await file.read()).decode("utf-8", errors="ignore")
    reader = csv.DictReader(io.StringIO(content))
    rows = [r for r in reader]
    print("Tenant ID:", tenant_id)
    if not rows:
        raise HTTPException(400, "CSV is empty")

    # Minimal required columns: name, price (optional), description (optional), image_url (optional)
    for r in rows:
        db.execute(text("""
            INSERT INTO items (tenant_id, name, price, description, image_url)
            VALUES (:t, :name, COALESCE(:price,0), :desc, :img)
        """), {
            "t": tenant_id,
            "name": r.get("name", "").strip(),
            "price": float(r["price"]) if r.get("price") else 0,
            "desc": (r.get("description") or "").strip(),
            "img": (r.get("image_url") or "").strip(),
        })

    db.commit()
    print("Tenant ID C:", tenant_id)
    # Optional: seed RAG quickly with the CSV content
    docs = []
    for r in rows:
        txt = f"{r.get('name','')} | {r.get('description','')} | Price: {r.get('price','')}"
        docs.append({"id": r.get("name",""), "text": txt, "source_url": "csv:upload", "version": "v1", "language": "en"})
    if docs:
        print("Tenant ID R:", tenant_id)
        await rag.add_documents(tenant_id, docs)

    return {"ok": True, "count": len(rows)}

# ---------- STEP 3b: Single Item (manual) ----------
@router.post("/items/manual")
async def add_item(
    tenant_id: int = Form(...),
    name: str = Form(...),
    price: Optional[float] = Form(0.0),
    description: Optional[str] = Form(""),
    image_url: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    db.execute(text("""
        INSERT INTO items (tenant_id, name, price, description, image_url)
        VALUES (:t,:n,:p,:d,:i)
    """), {"t": tenant_id, "n": name, "p": price or 0, "d": description or "", "i": image_url})
    db.commit()
    await rag.add_documents(tenant_id, [{"id": name, "text": f"{name} | {description} | Price: {price}", "source_url": "manual:add", "version":"v1", "language":"en"}])
    return {"ok": True}

# ---------- STEP 3c: Website link (auto-ingest) ----------
@router.post("/items/website")
async def add_website(
    tenant_id: int = Form(...),
    url: str = Form(...),
    db: Session = Depends(get_db),
    background_tasks: BackgroundTasks = BackgroundTasks(),

):
    result =  db.execute(
        text("SELECT tenant_id FROM business_profiles WHERE tenant_id = :tenant_id"),
        {"tenant_id": tenant_id}
    )
    existing = result.fetchone()

    if existing is None:
        return {
            "ok": False,
            "message": "Business profile with this tenant id not found",
        }
    # Store request for async ingestion by a crawler/worker you’ll run
    db.execute(text("""
        INSERT INTO web_ingest_requests (tenant_id, url, status)
        VALUES (:t,:u,'queued')
    """), {"t": tenant_id, "u": url})
    db.commit()
    # background_tasks.add_task(background_crawl, tenant_id, url)
    catalog = await background_crawl(tenant_id, url)
    return {"ok": True, "Bussiness_Catalog": catalog}

# ---------- STEP 4: Workflow Setup ----------
@router.post("/workflow")
async def set_workflow(
    tenant_id: int = Form(...),
    template: str = Form(...),
    ask_name: bool = Form(True),
    ask_location: bool = Form(False),
    offer_payment: bool = Form(True),
    qr_image_url: Optional[str] = Form(None),
    upi_id: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    # 1. Validate business profile exists
    business = db.query(BusinessProfile).filter(BusinessProfile.tenant_id == tenant_id).first()
    if not business:
        raise HTTPException(status_code=404, detail="Business profile not found for this tenant")

    # 2. Payment validation
    if offer_payment:
        if not qr_image_url and not upi_id:
            raise HTTPException(
                status_code=400,
                detail="If offer_payment is true, either qr_image_url or upi_id must be provided."
            )

    # 3. Try to find existing workflow
    workflow = db.query(Workflow).filter(Workflow.tenant_id == tenant_id).first()

    if workflow:
        # Update
        workflow.template = template
        workflow.ask_name = ask_name
        workflow.ask_location = ask_location
        workflow.offer_payment = offer_payment
        workflow.qr_image_url = qr_image_url
        workflow.upi_id = upi_id
        # updated_at auto-updates via onupdate=func.now()
    else:
        # Create
        workflow = Workflow(
            tenant_id=tenant_id,
            template=template,
            ask_name=ask_name,
            ask_location=ask_location,
            offer_payment=offer_payment,
            qr_image_url=qr_image_url,
            upi_id=upi_id,
            # created_at and updated_at auto-set
        )
        db.add(workflow)

    db.commit()
    db.refresh(workflow)

    return {"ok": True}

# ---------- STEP 5: Payments ----------
@router.post("/payments")
async def set_payments(
    tenant_id: int = Form(...),
    upi_id: Optional[str] = Form(None),
    bank_details: Optional[str] = Form(None),
    checkout_link: Optional[str] = Form(None),
    db: Session = Depends(get_db),
):
    db.execute(text("""
        INSERT INTO payments (tenant_id, upi_id, bank_details, checkout_link)
        VALUES (:t,:u,:b,:c)
        ON CONFLICT (tenant_id) DO UPDATE
         SET upi_id=:u, bank_details=:b, checkout_link=:c, updated_at=now()
    """), {"t": tenant_id, "u": upi_id, "b": bank_details, "c": checkout_link})
    db.commit()
    return {"ok": True}

# ---------- STEP 6: Review & Activate ----------
@router.post("/activate")
async def activate_agent(
    tenant_id: int = Form(...),
    db: Session = Depends(get_db),
):
    # Minimal validation: check business profile + one of items/workflow exists
    prof = (db.execute(text("SELECT 1 FROM business_profiles WHERE tenant_id=:t"), {"t": tenant_id})).first()
    if not prof:
        raise HTTPException(400, "Business profile missing")
    db.execute(text("UPDATE business_profiles SET is_active=true, updated_at=now() WHERE tenant_id=:t"), {"t": tenant_id})
    db.execute(text("UPDATE users SET onboarding_process=:op WHERE tenant_id=:t"), {"op": Onboarding.COMPLETED, "t": tenant_id})
    db.commit()
    return {"ok": True, "activated": True}


@router.post("/get_review", response_model=ReviewResponse, status_code=200)
async def get_review(
    tenant_id: int = Form(...),
    db: Session = Depends(get_db),
):
    # Check if business profile exists
    tenant = db.query(Tenant).filter(Tenant.id == tenant_id).first()
    business_profile = db.query(BusinessProfile).filter(BusinessProfile.tenant_id == tenant_id).first()
    if not business_profile:
        return ReviewResponse(
            tenant_id=tenant_id,
            onboarding_process=Onboarding.INPROCESS,
            has_business_profile=False,
            item_count=0,
            items=[],
        )

    # Query related data
    kyc = db.query(Kyc).filter(Kyc.tenant_id == tenant_id).first()
    payment = db.query(Payment).filter(Payment.tenant_id == tenant_id).first()
    workflow = db.query(Workflow).filter(Workflow.tenant_id == tenant_id).first()
    items = db.query(BusinessCatalog).filter(BusinessCatalog.tenant_id == tenant_id).all()
    web_ingest_request = db.query(WebIngestRequest).filter(WebIngestRequest.tenant_id == tenant_id).first()
    agent_configuration = db.query(AgentConfiguration).filter(AgentConfiguration.tenant_id == tenant_id).first()
    # Count items
    item_count = len(items)

    # Determine boolean flags
    has_business_type = bool(business_profile.business_type)  # Not None/empty
    has_items = item_count > 0
    has_web_ingest = web_ingest_request is not None
    has_agent_configuration = agent_configuration is not None
    has_profile_activate = business_profile.is_active  # True if activated

    # Prepare response data
    return ReviewResponse (
        tenant_id=tenant_id,
        onboarding_process = Onboarding.COMPLETED if has_profile_activate else Onboarding.INPROCESS,
        has_business_profile=bool(business_profile),
        has_business_type=has_business_type,
        has_items=has_items,
        has_web_ingest=has_web_ingest,
        has_workflow=bool(workflow),
        has_agent_configuration=has_agent_configuration,
        has_kyc=bool(kyc),
        has_payment=bool(payment),
        has_profile_activate=has_profile_activate,
        item_count=item_count,
        business_name=business_profile.business_name,
        business_whatsapp=business_profile.business_whatsapp, 
        personal_number=business_profile.personal_number,      
        language=business_profile.language,
        business_type=business_profile.business_type,
        business_description=business_profile.description,
        custom_business_type=business_profile.custom_business_type,
        business_category=business_profile.business_category,
        items=[{
            "id": item.id,
            "name": item.name,
            "description": item.description,
            "category": item.category,
            "price": float(item.price) if item.price is not None else None,
            "discount": float(item.discount) if item.discount is not None else None,
            "currency": item.currency,
            "image_url": item.image_url,
            "source_url": item.source_url,
        } for item in items],
        web_ingest={
            "id": str(web_ingest_request.id),
            "url": web_ingest_request.url,
            "status": web_ingest_request.status,
            "created_at": web_ingest_request.created_at.isoformat() if web_ingest_request.created_at else None,
        } if web_ingest_request else None,
        workflow={
            "id": workflow.tenant_id,
            "template": workflow.template,
            "ask_name": workflow.ask_name,
            "ask_location": workflow.ask_location,
            "offer_payment": workflow.offer_payment,
            "qr_image_url": workflow.qr_image_url,
            "upi_id": workflow.upi_id,
            "created_at": workflow.created_at.isoformat() if workflow.created_at else None,
            "updated_at": workflow.updated_at.isoformat() if workflow.updated_at else None,
        } if workflow else None,
        payment={
            "upi_id": payment.upi_id,
            "bank_details": payment.bank_details,
            "checkout_link": payment.checkout_link,
            "updated_at": payment.updated_at.isoformat() if payment.updated_at else None,
        } if payment else None,
        kyc={
            "id": kyc.id,
            "status": kyc.status,
            "aadhaar_number": kyc.aadhaar_number,
            "pan_number": kyc.pan_number,
            "document_image_url": kyc.document_image_url,
            "verified_at": kyc.verified_at.isoformat() if kyc.verified_at else None,
            "created_at": kyc.created_at.isoformat() if kyc.created_at else None,
            "updated_at": kyc.updated_at.isoformat() if kyc.updated_at else None,
        } if kyc else None,
        agent_configuration={
            "agent_name": agent_configuration.agent_name,
            "agent_image": agent_configuration.agent_image,
            "status": agent_configuration.status,
            "preferred_languages": agent_configuration.preferred_languages,
            "conversation_tone": agent_configuration.conversation_tone,
            "incoming_voice_message_enabled": agent_configuration.incoming_voice_message_enabled,
            "outgoing_voice_message_enabled": agent_configuration.outgoing_voice_message_enabled,
            "incoming_media_message_enabled": agent_configuration.incoming_media_message_enabled,
            "outgoing_media_message_enabled": agent_configuration.outgoing_media_message_enabled,
            "image_analyzer_enabled": agent_configuration.image_analyzer_enabled,
            "created_at": agent_configuration.created_at.isoformat() if agent_configuration.created_at else None,
            "updated_at": agent_configuration.updated_at.isoformat() if agent_configuration.updated_at else None,
        } if agent_configuration else None,
        tenant={
            "id": tenant.id,
            "name": tenant.name,
            "plan": tenant.plan,
            "rag_enabled": tenant.rag_enabled,
            "rag_updated_at": tenant.rag_updated_at.isoformat() if tenant.rag_updated_at else None,
            "created_at": tenant.created_at.isoformat() if tenant.created_at else None,
        } if tenant else None,
    )


@router.post("/agent-configurations", response_model=AgentConfigurationResponse)
def upsert_agent_configuration(
    config: AgentConfigurationBase,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    # Validate tenant exists
    tenant = db.query(Tenant).filter(Tenant.id == config.tenant_id).first()
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")

    # Try to find existing config for this tenant + agent_name
    existing = db.query(AgentConfiguration).filter(
        AgentConfiguration.tenant_id == config.tenant_id
       
    ).first()

    if existing:
        # UPDATE
        for field, value in config.dict(exclude_unset=True).items():
            setattr(existing, field, value)
        db.commit()
        db.refresh(existing)
        result = existing

    else:
        # CREATE
        new_config = AgentConfiguration(**config.dict())
        db.add(new_config)
        db.commit()
        db.refresh(new_config)
        result = new_config
    
    background_tasks.add_task(add_catalog_to_rag, tenant_id=config.tenant_id)
    
    return result

@router.post("/get_onboarding_status", response_model=StatusResponse, status_code=200)
async def get_review(
    tenant_id: int,
    db: Session = Depends(get_db),
):
    # Check if business profile exists
    tenant = db.query(Tenant).filter(Tenant.id == tenant_id).first()
    if not tenant:
        raise HTTPException(status_code=404, detail="Tenant not found")
    
    user = db.query(User).filter(User.tenant_id == tenant_id).first()
    if not user:    
        raise HTTPException(status_code=404, detail="User not found")
    
    if user.onboarding_process == Onboarding.COMPLETED:
        return StatusResponse(
            tenant_id=tenant_id,
            onboarding_process=Onboarding.COMPLETED,
            onboarding_steps={
                "AI_Agent_Configuration": True,
                "Knowledge_Base_Ingestion": True,
                "template_Messages_Setup": True,
            }
            )

    agent_config  = db.query(AgentConfiguration).filter(AgentConfiguration.tenant_id == tenant_id).first()
    if not agent_config:
        return StatusResponse(
            tenant_id=tenant_id,
            onboarding_process=Onboarding.INPROCESS,
            onboarding_steps={
                "AI_Agent_Configuration": False,
                "Knowledge_Base_Ingestion": False,
                "template_Messages_Setup": False,
            }
            )
    
    knowledge_base = db.query(KnowledgeSource).filter(KnowledgeSource.tenant_id == tenant_id).first()
    if not knowledge_base:
        return StatusResponse(
            tenant_id=tenant_id,
            onboarding_process=Onboarding.INPROCESS,
            onboarding_steps={
                "AI_Agent_Configuration": True,
                "Knowledge_Base_Ingestion": False,
                "template_Messages_Setup": False,
            }
            )
    template_messages = db.query(Template).filter(Template.tenant_id == tenant_id).first()
    if not template_messages:
        return StatusResponse(
            tenant_id=tenant_id,
            onboarding_process=Onboarding.INPROCESS,
            onboarding_steps={
                "AI_Agent_Configuration": True,
                "Knowledge_Base_Ingestion": True,
                "template_Messages_Setup": False,
            }
            )
    
    return StatusResponse(
            tenant_id=tenant_id,
            onboarding_process=Onboarding.INPROCESS,
            onboarding_steps={
                "AI_Agent_Configuration": True,
                "Knowledge_Base_Ingestion": True,
                "template_Messages_Setup": True,
            }
            )
            

def get_tanant_id_from_receiver(receiver: str) -> int:
    db = SessionLocal()
    try:
        business_profile = db.query(BusinessProfile).filter(BusinessProfile.business_whatsapp == receiver).first()
        if business_profile:
            return business_profile.tenant_id
        else: return 1
    except Exception as e:
        print(f"Error fetching : {e}")
    finally:
        db.close()
    
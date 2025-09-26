# server/routers/onboarding.py
import random
from fastapi import APIRouter, UploadFile, File, Form, HTTPException, Depends
from fastapi.responses import JSONResponse
from typing import Optional, List, Literal
from requests import Session
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncSession
import csv, io, json
from deps import get_db
from services.rag import rag

router = APIRouter(prefix="/onboarding", tags=["onboarding"])

# ---------- STEP 1: Business Profile ----------
@router.post("/business")
async def upsert_business_profile(
    business_name: str = Form(...),
    owner_phone: str = Form(...),
    language: str = Form("en"),
    db: Session = Depends(get_db),
):
    # Step 1: Check if owner_phone already exists
    result =  db.execute(
        text("SELECT tenant_id FROM business_profiles WHERE owner_phone = :phone"),
        {"phone": owner_phone}
    )
    existing = result.fetchone()

    if existing:
        return {
            "ok": False,
            "message": "Business profile with this phone number already exists",
            "tenant_id": existing.tenant_id
        }
    print("No existing profile, creating new one."+str(existing))
    # Step 2: Generate tenant_id = business_name + 8-digit random number
    clean_name = "".join(c if c.isalnum() else "" for c in business_name)[:20]
    if not clean_name:
        clean_name = "business"
    random_digits = random.randint(10000000, 99999999)
    tenant_id = f"{clean_name}{random_digits}"

    # # Optional: Retry logic in case tenant_id collision (unlikely but possible)
    # for _ in range(3):
    #     check_tenant = db.execute(
    #         text("SELECT 1 FROM business_profiles WHERE tenant_id = :tid"),
    #         {"tid": tenant_id}
    #     )
    #     if not check_tenant.fetchone():
    #         break
    #     random_digits = random.randint(10000000, 99999999)
    #     tenant_id = f"{clean_name}{random_digits}"
    # else:
    #     raise HTTPException(status_code=500, detail="Could not generate unique tenant_id after retries")

    # Step 3: Insert new record
    db.execute(
        text("""
            INSERT INTO business_profiles (tenant_id, business_name, owner_phone, language)
            VALUES (:t, :n, :p, :l)
        """),
        {
            "t": tenant_id,
            "n": business_name,
            "p": owner_phone,
            "l": language
        }
    )
    db.commit()

    return {
        "ok": True,
        "message": "Business profile created successfully",
        "tenant_id": tenant_id
    }


# ---------- STEP 2: Business Type ----------
@router.post("/type")
async def set_business_type(
    tenant_id: str = Form(...),
    business_type: Literal["products","services","professional","other"] = Form(...),
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
    db.execute(text("UPDATE business_profiles SET business_type=:bt, updated_at=now() WHERE tenant_id=:t"),
                     {"bt": business_type, "t": tenant_id})
    db.commit()
    return {"ok": True,
            "message": "Business Type Updated Successfully",
             "tenant_id": tenant_id
           }

# ---------- STEP 3a: Items via CSV (products/services) ----------
@router.post("/items/csv")
async def upload_items_csv(
    tenant_id: str = Form(...),
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
    tenant_id: str = Form(...),
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
    tenant_id: str = Form(...),
    url: str = Form(...),
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
    # Store request for async ingestion by a crawler/worker you’ll run
    db.execute(text("""
        INSERT INTO web_ingest_requests (tenant_id, url, status)
        VALUES (:t,:u,'queued')
    """), {"t": tenant_id, "u": url})
    db.commit()
    return {"ok": True, "status": "queued"}

# ---------- STEP 4: Workflow Setup ----------
@router.post("/workflow")
async def set_workflow(
    tenant_id: str = Form(...),
    template: str = Form(...),
    ask_name: bool = Form(True),
    ask_location: bool = Form(False),
    offer_payment: bool = Form(True),
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
    db.execute(text("""
        INSERT INTO workflows (tenant_id, template, ask_name, ask_location, offer_payment)
        VALUES (:t,:tpl,:an,:al,:op)
        ON CONFLICT (tenant_id) DO UPDATE
         SET template=:tpl, ask_name=:an, ask_location=:al, offer_payment=:op, updated_at=now()
    """), {"t": tenant_id, "tpl": template, "an": ask_name, "al": ask_location, "op": offer_payment})
    db.commit()
    return {"ok": True}

# ---------- STEP 5: Payments ----------
@router.post("/payments")
async def set_payments(
    tenant_id: str = Form(...),
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
    tenant_id: str = Form(...),
    db: Session = Depends(get_db),
):
    # Minimal validation: check business profile + one of items/workflow exists
    prof = (db.execute(text("SELECT 1 FROM business_profiles WHERE tenant_id=:t"), {"t": tenant_id})).first()
    if not prof:
        raise HTTPException(400, "Business profile missing")
    db.execute(text("UPDATE business_profiles SET is_active=true, updated_at=now() WHERE tenant_id=:t"), {"t": tenant_id})
    db.commit()
    return {"ok": True, "activated": True}

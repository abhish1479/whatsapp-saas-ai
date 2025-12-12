from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from database import SessionLocal
from models import Tenant, User, Wallet
from deps import create_token
from services.erp import ERPNextClient

router = APIRouter()

class Signup(BaseModel):
    business_name: str
    email: EmailStr
    password: str


@router.post("/signup")
def signup(body: Signup):  
    db = SessionLocal()
    erp = ERPNextClient()
    try:
        if db.query(User).filter_by(email=body.email).first():
            raise HTTPException(400, "Email in use")
        tenant = Tenant(name=body.business_name)
        db.add(tenant)
        db.flush()
        
        user = User(
            tenant_id=tenant.id,
            email=body.email,
            name=body.business_name,
            password_hash=body.password
        )
        db.add(user)
        db.flush()
        # Create wallet
        wallet = Wallet(tenant_id=tenant.id, credits_balance=500)
        db.add(wallet)      
        # Prepare ERPNext payload
        erp_payload = {
            "company_name": body.business_name,
            "user_email": body.email,
            "first_name": body.business_name.split(" ")[0] if body.business_name.split() else body.business_name,
        }

        print("⚪ ERP PAYLOAD:", erp_payload)
        print("🔥 ABOUT TO CALL ERP...")

        try:
            erp_response = erp.onboard_company(erp_payload)
            print(f"✅ERPNext onboarding successful: {erp_response}")
        except Exception as e:
            print(f"ERPNext onboarding failed: {str(e)}")
        db.commit()
        return {
            "access_token": create_token(user.id, tenant.id),
            "token_type": "bearer",
            "user": {
                "id": user.id,
                "email": user.email,
                "name": tenant.name,
                "picture": "",
                "provider": "Self",
                "provider_id": 0,
                "role": user.role,
            },
            "tenant_id": tenant.id,
            "onboarding_process": user.onboarding_process,
        }
    finally:
        db.close()

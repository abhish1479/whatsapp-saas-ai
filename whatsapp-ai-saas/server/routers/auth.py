
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, EmailStr
from database import SessionLocal
from models import Tenant, User, Wallet
from passlib.hash import bcrypt
import hashlib
from deps import create_token

router = APIRouter()

class Signup(BaseModel):
    business_name:str
    email:EmailStr
    password:str

@router.post("/signup")
def signup(body:Signup):
    db = SessionLocal()
    try:
        if db.query(User).filter_by(email=body.email).first():
            raise HTTPException(400,"Email in use")
        tenant = Tenant(name=body.business_name)
        db.add(tenant); db.flush()
        user = User(tenant_id=tenant.id, email=body.email, password_hash=body.password)
        db.add(user); db.flush()
        db.add(Wallet(tenant_id=tenant.id, credits_balance=500))
        db.commit()
        return {"token": create_token(user.id, tenant.id), "tenant_id": tenant.id}
    finally:
        db.close()

class Login(BaseModel):
    email:EmailStr
    password:str

@router.post("/login")
def login(body:Login):
    db = SessionLocal()
    try:
        u = db.query(User).filter_by(email=body.email , password_hash=body.password).first()
        if not u :  #or not pwd_context.verify(body.password, u.password_hash):
            raise HTTPException(401,"Invalid credentials")
        return {"token": create_token(u.id, u.tenant_id)}
    finally:
        db.close()


from fastapi import Header, HTTPException
import jwt, datetime
from settings import settings
from database import SessionLocal

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def create_token(user_id:int, tenant_id:int):
    payload = {
        "uid": user_id, "tid": tenant_id,
        "exp": datetime.datetime.utcnow() + datetime.timedelta(minutes=settings.JWT_EXPIRE_MIN)
    }
    return jwt.encode(payload, settings.JWT_SECRET, algorithm="HS256")

def get_current(Authorization: str = Header(None)):
    if not Authorization: raise HTTPException(401,"Missing Authorization header")
    try:
        scheme, token = Authorization.split()
        assert scheme.lower()=="bearer"
        data = jwt.decode(token, settings.JWT_SECRET, algorithms=["HS256"])
        return data
    except Exception:
        raise HTTPException(401,"Invalid token")

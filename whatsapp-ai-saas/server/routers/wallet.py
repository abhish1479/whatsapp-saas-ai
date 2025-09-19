
from fastapi import APIRouter, Depends
from deps import get_current
from services.credits import ensure_wallet, credit
from database import SessionLocal

router = APIRouter()

@router.get("")
def get_wallet(ident=Depends(get_current)):
    db = SessionLocal()
    try:
        w = ensure_wallet(db, ident['tid'])
        return {"credits": w.credits_balance}
    finally:
        db.close()

@router.post("/recharge")
def recharge(amount:int, ident=Depends(get_current)):
    db = SessionLocal()
    try:
        bal = credit(db, ident['tid'], amount, "manual_recharge")
        return {"credits": bal}
    finally:
        db.close()

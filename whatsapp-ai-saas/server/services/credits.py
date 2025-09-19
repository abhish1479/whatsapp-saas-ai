
from sqlalchemy.orm import Session
from models import Wallet, WalletTx
from settings import settings

def ensure_wallet(db:Session, tenant_id:int):
    w = db.query(Wallet).filter_by(tenant_id=tenant_id).first()
    if not w:
        w = Wallet(tenant_id=tenant_id, credits_balance=settings.FREE_TRIAL_CREDITS)
        db.add(w); db.commit()
    return w

def debit(db:Session, tenant_id:int, amount:int, reason:str, ref_id:str=None):
    w = ensure_wallet(db, tenant_id)
    if w.credits_balance < amount:
        raise ValueError("Insufficient credits")
    w.credits_balance -= amount
    tx = WalletTx(tenant_id=tenant_id, delta=-amount, reason=reason, ref_id=ref_id)
    db.add(tx); db.commit()
    return w.credits_balance

def credit(db:Session, tenant_id:int, amount:int, reason:str, ref_id:str=None):
    w = ensure_wallet(db, tenant_id)
    w.credits_balance += amount
    tx = WalletTx(tenant_id=tenant_id, delta=amount, reason=reason, ref_id=ref_id)
    db.add(tx); db.commit()
    return w.credits_balance

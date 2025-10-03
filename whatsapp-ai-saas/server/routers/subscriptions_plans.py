
from fastapi import APIRouter, Depends
from requests import Session

from data_models.subscriptions_models import SubscriptionPlanResponse
from deps import get_db
from models import SubscriptionPlan


router = APIRouter(prefix="/subscriptions", tags=["subscriptions"])


@router.get("/get_all_plans", response_model=list[SubscriptionPlanResponse])
def get_all_subscriptions(db: Session = Depends(get_db)):
    subscriptions = db.query(SubscriptionPlan).all()
    return subscriptions  
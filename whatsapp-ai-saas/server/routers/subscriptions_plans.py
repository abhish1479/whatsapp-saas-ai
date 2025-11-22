
from fastapi import APIRouter, Depends, HTTPException
from requests import Session
from sqlalchemy import func

from data_models.subscriptions_models import SubscriptionPlanResponse
from deps import get_db
from models import SubscriptionPlan
from data_models.subscriptions_models import SubscriptionPlanCreate, SubscriptionPlanUpdate
from starlette import status


router = APIRouter(prefix="/subscriptions", tags=["subscriptions"])


# @router.get("/get_all_plans", response_model=list[SubscriptionPlanResponse])
# def get_all_subscriptions(db: Session = Depends(get_db)):
#     subscriptions = db.query(SubscriptionPlan).all()
#     return subscriptions  

@router.get("/get_all_plans", response_model=list[SubscriptionPlanResponse])
def get_all_subscriptions(db: Session = Depends(get_db)):
    subscriptions = db.query(SubscriptionPlan).all()
    
    # 🔧 TEMPORARY: Seed default plans if table is empty (for dev/testing only)
    if not subscriptions:
        basic = SubscriptionPlan(
            name="Starter",
            price=999.0,
            price_per_month=999.0,
            credits=1000,
            duration_days=30,
            billing_cycle="month",
            features='["Basic AI features", "Email support", "5 projects limit"]',
            category = "whatsapp",  
            is_popular=False,
            created_at=func.now(),
            updated_at=func.now()
        )
        premium = SubscriptionPlan(
            name="Growth",
            price=1999.0,
            price_per_month=1999.0,
            credits=5000,
            duration_days=30,
            billing_cycle="month",
            features='["Advanced AI features", "Priority support", "Unlimited projects", "Analytics dashboard"]',
            category = "whatsapp",  
            is_popular=True,
            created_at=func.now(),
            updated_at=func.now()
        )
        mega = SubscriptionPlan(
            name="Professional",
            price=3999.0,
            price_per_month=3999.0,
            credits=15000,
            duration_days=30,
            billing_cycle="month",
            features='["All premium features", "24/7 phone support", "Custom integrations", "Dedicated account manager"]',
            category = "whatsapp",  
            is_popular=False,
            created_at=func.now(),
            updated_at=func.now()
        )
        db.add_all([basic, premium, mega])
        db.commit()
        db.refresh(basic)
        db.refresh(premium)
        db.refresh(mega)
        subscriptions = [basic, premium, mega]

    return subscriptions

@router.get("/{plan_id}", response_model=SubscriptionPlanResponse)
def get_subscription_plan(plan_id: int, db: Session = Depends(get_db)):
    plan = db.query(SubscriptionPlan).filter(SubscriptionPlan.id == plan_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="Subscription plan not found")
    return plan

# ✅ CREATE new plan
@router.post("/", response_model=SubscriptionPlanResponse, status_code=status.HTTP_201_CREATED)
def create_subscription_plan(
    plan: SubscriptionPlanCreate,
    db: Session = Depends(get_db)
):
    # Check if name already exists
    existing = db.query(SubscriptionPlan).filter(SubscriptionPlan.name == plan.name).first()
    if existing:
        raise HTTPException(
            status_code=400,
            detail=f"Subscription plan with name '{plan.name}' already exists"
        )

    # Create new plan
    db_plan = SubscriptionPlan(**plan.model_dump())
    db.add(db_plan)
    db.commit()
    db.refresh(db_plan)
    return db_plan

# ✅ UPDATE existing plan
@router.put("/{plan_id}", response_model=SubscriptionPlanResponse)
def update_subscription_plan(
    plan_id: int,
    plan_update: SubscriptionPlanUpdate,
    db: Session = Depends(get_db)
):
    db_plan = db.query(SubscriptionPlan).filter(SubscriptionPlan.id == plan_id).first()
    if not db_plan:
        raise HTTPException(status_code=404, detail="Subscription plan not found")

    # Prevent updating name to an existing one
    if plan_update.name and plan_update.name != db_plan.name:
        existing = db.query(SubscriptionPlan).filter(SubscriptionPlan.name == plan_update.name).first()
        if existing:
            raise HTTPException(
                status_code=400,
                detail=f"Another plan with name '{plan_update.name}' already exists"
            )

    # Update fields
    for key, value in plan_update.model_dump(exclude_unset=True).items():
        setattr(db_plan, key, value)

    db.commit()
    db.refresh(db_plan)
    return db_plan

# ✅ DELETE plan
@router.delete("/{plan_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_subscription_plan(
    plan_id: int,
    db: Session = Depends(get_db)
):
    plan = db.query(SubscriptionPlan).filter(SubscriptionPlan.id == plan_id).first()
    if not plan:
        raise HTTPException(status_code=404, detail="Subscription plan not found")

    # Optional: Prevent deletion if plans are in use by customers
    # You can add logic here to check if any user has this plan active
    # Example: if db.query(UserSubscription).filter(UserSubscription.plan_id == plan_id).count() > 0:
    #   raise HTTPException(400, "Cannot delete plan: it's currently in use")

    db.delete(plan)
    db.commit()
    return None  # FastAPI expects None for 204

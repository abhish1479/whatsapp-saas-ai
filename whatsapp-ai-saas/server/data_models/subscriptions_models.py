# schemas.py
from pydantic import BaseModel, Field, field_validator, validator
from typing import List, Optional
from datetime import datetime
import json

class SubscriptionPlanBase(BaseModel):
    name: str
    price: float
    price_per_month: float
    credits: int
    duration_days: int
    billing_cycle: Optional[str] = None
    features: List[str]  # ✅ Must be list, not string
    is_popular: bool

    class Config:
        from_attributes = True  # Enables ORM mode

class SubscriptionPlanResponse(SubscriptionPlanBase):
    id: int
    created_at: str
    updated_at: str

    # ✅ Auto-convert JSON string → list for features
    @field_validator("features", mode="before")
    @classmethod
    def parse_features(cls, v):
        if isinstance(v, str):
            try:
                return json.loads(v)
            except json.JSONDecodeError:
                return []  # fallback
        return v

    # ✅ Auto-convert datetime → ISO string for created_at and updated_at
    @field_validator("created_at", "updated_at", mode="before")
    @classmethod
    def format_datetime(cls, v):
        if isinstance(v, datetime):
            return v.isoformat()  # Converts to "2025-10-03T07:08:01.295120+00:00"
        return v  # if already string, leave as-is
    

class SubscriptionPlanBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=50, description="Plan name (e.g., 'Starter', 'Pro')")
    price: float = Field(..., gt=0, description="Total price for the plan duration")
    price_per_month: float = Field(..., gt=0, description="Normalized price per month")
    credits: int = Field(..., gt=0, description="Number of credits included")
    duration_days: int = Field(..., gt=0, description="Duration in days (e.g., 30, 365)")
    billing_cycle: Optional[str] = Field(None, pattern=r"^(month|year|half-year)$", description="Billing cycle: 'month', 'year', 'half-year'")
    features: str = Field(..., description="JSON string of features (e.g., '[\"Unlimited messages\", \"Priority support\"]')")
    is_popular: bool = False

    @validator("features")
    def validate_features_json(cls, v):
        import json
        try:
            parsed = json.loads(v)
            if not isinstance(parsed, list):
                raise ValueError("Features must be a JSON array")
            return v
        except json.JSONDecodeError:
            raise ValueError("Features must be a valid JSON array")

class SubscriptionPlanCreate(SubscriptionPlanBase):
    pass

class SubscriptionPlanUpdate(SubscriptionPlanBase):
    name: Optional[str] = None
    price: Optional[float] = None
    price_per_month: Optional[float] = None
    credits: Optional[int] = None
    duration_days: Optional[int] = None
    billing_cycle: Optional[str] = None
    features: Optional[str] = None
    is_popular: Optional[bool] = None

class SubscriptionPlanResponse(SubscriptionPlanBase):
    id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True  # For SQLAlchemy ORM models
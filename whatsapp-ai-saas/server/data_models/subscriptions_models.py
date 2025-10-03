# schemas.py
from pydantic import BaseModel, field_validator
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
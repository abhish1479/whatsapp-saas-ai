# schemas.py
import json
from pydantic import BaseModel, Field, field_validator
from typing import Any, List, Optional
from datetime import datetime

class SubscriptionPlanBase(BaseModel):
    name: str = Field(..., min_length=1, max_length=50, description="Plan name (e.g., 'Starter', 'Pro')")
    price: float = Field(..., gt=0, description="Total price for the plan duration")
    price_per_month: float = Field(..., gt=0, description="Normalized price per month")
    credits: int = Field(..., gt=0, description="Number of credits included")
    duration_days: int = Field(..., gt=0, description="Duration in days (e.g., 30, 365)")
    billing_cycle: Optional[str] = Field(
        None,
        pattern=r"^(month|year|half-year)$",
        description="Billing cycle: 'month', 'year', 'half-year'"
    )
    features: List[str] = Field(..., min_items=1, description="List of feature strings")
    is_popular: bool = False

    @field_validator("features")
    @classmethod
    def validate_features_not_empty(cls, v: List[str]) -> List[str]:
        if not v:
            raise ValueError("Features list cannot be empty")
        if not all(isinstance(item, str) and item.strip() for item in v):
            raise ValueError("Each feature must be a non-empty string")
        return [item.strip() for item in v]

class SubscriptionPlanCreate(SubscriptionPlanBase):
    pass

class SubscriptionPlanUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=1, max_length=50)
    price: Optional[float] = Field(None, gt=0)
    price_per_month: Optional[float] = Field(None, gt=0)
    credits: Optional[int] = Field(None, gt=0)
    duration_days: Optional[int] = Field(None, gt=0)
    billing_cycle: Optional[str] = Field(None, pattern=r"^(month|year|half-year)$")
    features: Optional[List[str]] = Field(None, min_items=1)
    is_popular: Optional[bool] = None

    @field_validator("features")
    @classmethod
    def validate_features_update(cls, v: Optional[List[str]]) -> Optional[List[str]]:
        if v is None:
            return v
        if not all(isinstance(item, str) and item.strip() for item in v):
            raise ValueError("Each feature must be a non-empty string")
        return [item.strip() for item in v]

class SubscriptionPlanResponse(BaseModel):
    id: int
    name: str
    price: float
    price_per_month: float
    credits: int
    duration_days: int
    billing_cycle: Optional[str]
    features: List[str]
    is_popular: bool
    created_at: datetime
    updated_at: datetime

    @field_validator("features", mode="before")
    @classmethod
    def parse_features_from_string(cls, v: Any) -> List[str]:
        if isinstance(v, str):
            try:
                parsed = json.loads(v)
                if isinstance(parsed, list) and all(isinstance(x, str) for x in parsed):
                    return parsed
                else:
                    raise ValueError("Features must be a list of strings")
            except json.JSONDecodeError:
                raise ValueError("Features must be a valid JSON array")
        elif isinstance(v, list):
            return v
        else:
            raise ValueError("Features must be a list or JSON string")

    class Config:
        from_attributes = True
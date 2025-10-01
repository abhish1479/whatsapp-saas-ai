
from typing import Optional
from anthropic import BaseModel
from utils.enums import SocialProvider


class SocialLoginRequest(BaseModel):
    provider: str
    id_token: str
    is_Login: bool = False
    plan: Optional[str] = None
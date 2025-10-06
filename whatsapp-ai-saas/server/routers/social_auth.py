from datetime import datetime, timedelta
from typing import Optional
from fastapi import APIRouter, FastAPI, HTTPException, Depends
from sqlalchemy.orm import Session
from data_models.social_auth_model import SocialLoginRequest
from utils.google_jwt import verify_google_id_token
from utils.enums import SocialProvider
from services.social_auth_service import SocialAuthService
from utils.jwt_utils import create_access_token
from models import Tenant, User, Identity  # Import your DB setup
from pydantic import BaseModel
from deps import get_db

router = APIRouter()

# class SocialLoginRequest(BaseModel):
#     provider: SocialProvider
#     code: str

@router.get("/auth/{provider}/callback")
async def oauth_callback(
    provider: SocialProvider,
    code: str,
    state: Optional[str] = None,
    db: Session = Depends(get_db)
):
    """
    Single endpoint for Google/Facebook/LinkedIn login.
    Returns JWT with user info.
    No cookies, no refresh tokens.
    """
    try:
        # Step 1: Exchange code for user info
        print("Provider:", provider, "Code:", code)
        user_info = await SocialAuthService.exchange_code_for_tokens(provider, code)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid code or provider error: {str(e)}")

    email = user_info["email"]
    name = user_info["name"]
    provider_id = user_info["provider_id"]
    access_token = user_info.get("access_token")
    extra_data = user_info.get("extra_data")

    # Step 2: Find existing Identity
    identity = db.query(Identity).filter(
        Identity.provider == provider.value,
        Identity.provider_id == provider_id
    ).first()

    if identity:
        # User exists via this provider
        user = identity.user
    else:
        # Create new user + identity
        user = None
        if email:
            # Try to find user by email (if email is provided)
            user = db.query(User).filter(User.email == email).first()

        if not user:
            # Create new user
            tenant = Tenant(name=name)  # Default plan if none
            db.add(tenant); db.flush()
            user = User(
                tenant_id=tenant.id,  # Adjust as needed
                email=email or f"{provider_id}@{provider.value}.com",  # Fallback
                password_hash="",  # No password — social login only
                role="user",
            )
            db.add(user)
            db.flush()  # To get user.id

        # Create Identity
        identity = Identity(
            user_id=user.id,
            provider=provider.value,
            provider_id=provider_id,
            email=email,
            access_token=access_token,
            refresh_token=None,
            expires_at=None,
            extra_data=extra_data
        )
        db.add(identity)

    db.commit()

    # Step 3: Create JWT payload
    token_payload = {
        "user_id": user.id,
        "email": user.email,
        "name": name,
        "provider": provider.value,
        "provider_id": provider_id,
    }

    # Step 4: Return JWT
    access_token_jwt = create_access_token(token_payload)
    return {
        "access_token": access_token_jwt,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "email": user.email,
            "name": name,
            "provider": provider.value,
            "provider_id": provider_id
        },
        "tenant_id": user.tenant_id,
        "onboarding_process": user.onboarding_process
    }


@router.post("/social_auth/login")
async def oauth_callback(
    request: SocialLoginRequest, 
    db: Session = Depends(get_db)
):
    """
    Single endpoint for Google/Facebook/LinkedIn login.
    Returns JWT with user info.
    No cookies, no refresh tokens.
    """
    provider = request.provider
    id_token = request.id_token
    plan = request.plan

    try:
        # Step 1: Verify ID token (Google example — adapt for FB/LinkedIn)
        print("Provider:", provider, "ID Token:", id_token)
        #print("google :", SocialProvider.google)
        if provider == "google":
            print("Google :-----" )
            payload = verify_google_id_token(id_token)
        # elif provider == SocialProvider.facebook:
        #     payload = verify_facebook_access_token(id_token)  # You'll implement this
        # elif provider == SocialProvider.linkedin:
        #     payload = verify_linkedin_id_token(id_token)     # You'll implement this
        else:
            raise HTTPException(400, detail="Unsupported provider")

    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid token or provider error: {str(e)}")

    # Extract user info from token
    user_email = payload.get("email") # Use provided email if token lacks it
    name = payload.get("name", "")
    picture = payload.get("picture", "")
    provider_id = payload.get("sub") or payload.get("id")  # Google uses "sub", Facebook uses "id"
    access_token = payload.get("access_token")  # Optional — store if provided
    extra_data = payload

    # Step 2: Find existing Identity
    identity = db.query(Identity).filter(
        Identity.provider == provider,
        Identity.provider_id == provider_id
    ).first()

    if identity:
        # User exists via this provider
        user = identity.user
    else:
        # Create new user + identity
        user = None
        if user_email:
            # Try to find user by email (if email is provided)
            user = db.query(User).filter(User.email == user_email).first()

        if not user:
            # Create new use
            tenant = Tenant(name=name, plan=plan)  # Default plan if none
            db.add(tenant)
            db.flush()  # To get tenant.id
            user = User(
                tenant_id=tenant.id,
                email=user_email,  # Fallback
                password_hash="",  # No password — social login only
                role="user",
            )
            db.add(user)
            db.flush()  # To get user.id

        # Create Identity
        identity = Identity(
            user_id=user.id,
            provider=provider,
            provider_id=provider_id,
            email=user_email,
            access_token=access_token,
            refresh_token=None,
            expires_at=None,
            extra_data=extra_data
        )
        db.add(identity)

    db.commit()

    # Step 3: Create JWT payload
    token_payload = {
        "user_id": user.id,
        "email": user.email,
        "name": name,
        "provider": provider,
        "provider_id": provider_id,
        "tenant_id": user.tenant_id,
        "role": user.role,
        "iat": datetime.utcnow(),  # Optional: issued at
        "exp": datetime.utcnow() + timedelta(minutes=30)  # Optional: explicit expiry
    }

    # Step 4: Generate JWT
    access_token_jwt = create_access_token(token_payload)

    # Step 5: Return response
    return {
        "access_token": access_token_jwt,
        "token_type": "bearer",
        "user": {
            "id": user.id,
            "email": user.email,
            "name": name,
            "picture" : picture,
            "provider": provider,
            "provider_id": provider_id,
            "role": user.role,
        },
        "tenant_id": user.tenant_id,
        "onboarding_process": user.onboarding_process
    }
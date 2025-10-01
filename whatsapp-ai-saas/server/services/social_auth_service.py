# social_auth_service.py
from http.client import HTTPException
import os
from dotenv import load_dotenv
import httpx
from typing import Dict, Any
from utils.enums import SocialProvider
from utils.google_jwt import verify_google_id_token
from google_auth_oauthlib.flow import Flow
from sqlalchemy.orm import Session
from models import User, Identity

load_dotenv()

GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")
GOOGLE_CLIENT_SECRET = os.getenv("GOOGLE_CLIENT_SECRET")
GOOGLE_REDIRECT_URI = os.getenv("GOOGLE_REDIRECT_URI")

if not all([GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI]):
    raise ValueError(
        "Missing Google OAuth environment variables: GOOGLE_CLIENT_ID, "
        "GOOGLE_CLIENT_SECRET, GOOGLE_REDIRECT_URI"
    )

# Define OAuth2 scopes
SCOPES = [
    "openid",
    "https://www.googleapis.com/auth/userinfo.email",
    "https://www.googleapis.com/auth/userinfo.profile"
]

# Build client config from env vars (no file needed!)
CLIENT_CONFIG = {
    "web": {
        "client_id": GOOGLE_CLIENT_ID,
        "client_secret": GOOGLE_CLIENT_SECRET,
        "auth_uri": "https://accounts.google.com/o/oauth2/auth",
        "token_uri": "https://oauth2.googleapis.com/token",
    }
}

class SocialAuthService:
    @staticmethod
    async def exchange_code_for_tokens(provider: SocialProvider, code: str) -> Dict[str, Any]:
        if provider == SocialProvider.GOOGLE:
            return await SocialAuthService._exchange_google(code)
        elif provider == SocialProvider.FACEBOOK:
            return await SocialAuthService._exchange_facebook(code)
        elif provider == SocialProvider.LINKEDIN:
            return await SocialAuthService._exchange_linkedin(code)
        else:
            raise ValueError(f"Unsupported provider: {provider}")

    @staticmethod
    async def _exchange_google(code: str) -> Dict[str, Any]:
        print("Exchanging code for Google tokens...")
        flow = Flow.from_client_config(
            client_config=CLIENT_CONFIG,
            scopes=SCOPES,
            redirect_uri=GOOGLE_REDIRECT_URI
        )
        print("Flow created with redirect URI:", flow.redirect_uri)
        # Exchange code for credentials
        flow.fetch_token(code=code)
        
        print("Credentials fetched:", flow.credentials)
        # Extract ID token (JWT) from credentials
        id_token_str = flow.credentials.id_token
        print("Google ID Token:", id_token_str)
        if not id_token_str:
            raise HTTPException(status_code=400, detail="No ID token received from Google")

        payload = verify_google_id_token(id_token_str)
        return {
            "email": payload["email"],
            "name": payload.get("name", ""),
            "provider_id": payload["sub"],
            #"access_token": data.get("access_token"),
            "extra_data": payload,
        }

    @staticmethod
    async def _exchange_facebook(code: str) -> Dict[str, Any]:
        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://graph.facebook.com/v18.0/oauth/access_token",
                params={
                    "client_id": os.getenv("FACEBOOK_CLIENT_ID"),
                    "client_secret": os.getenv("FACEBOOK_CLIENT_SECRET"),
                    "code": code,
                    "redirect_uri": os.getenv("FACEBOOK_REDIRECT_URI"),
                },
            )
            response.raise_for_status()
            token_data = response.json()

            access_token = token_data.get("access_token")
            if not access_token:
                raise ValueError("No access_token from Facebook")

            user_response = await client.get(
                "https://graph.facebook.com/v18.0/me",
                params={
                    "fields": "id,name,email",
                    "access_token": access_token,
                },
            )
            user_response.raise_for_status()
            user_data = user_response.json()

        return {
            "email": user_data.get("email"),
            "name": user_data.get("name", ""),
            "provider_id": user_data["id"],
            "access_token": access_token,
            "extra_data": user_data,
        }

    @staticmethod
    async def _exchange_linkedin(code: str) -> Dict[str, Any]:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://www.linkedin.com/oauth/v2/accessToken",
                data={
                    "grant_type": "authorization_code",
                    "code": code,
                    "redirect_uri": os.getenv("LINKEDIN_REDIRECT_URI"),
                    "client_id": os.getenv("LINKEDIN_CLIENT_ID"),
                    "client_secret": os.getenv("LINKEDIN_CLIENT_SECRET"),
                },
                headers={"Content-Type": "application/x-www-form-urlencoded"},
            )
            response.raise_for_status()
            token_data = response.json()

            access_token = token_data.get("access_token")
            if not access_token:
                raise ValueError("No access_token from LinkedIn")

            user_response = await client.get(
                "https://api.linkedin.com/v2/me",
                headers={
                    "Authorization": f"Bearer {access_token}",
                    "X-Restli-Protocol-Version": "2.0.0",
                },
                params={"projection": "(id,firstName,lastName)"},
            )
            user_response.raise_for_status()
            user_data = user_response.json()

            email_response = await client.get(
                "https://api.linkedin.com/v2/emailAddress",
                headers={"Authorization": f"Bearer {access_token}"},
            )
            email_response.raise_for_status()
            email_data = email_response.json()
            email = email_data.get("elements", [{}])[0].get("handle", "").replace("mailto:", "")

        return {
            "email": email,
            "name": f"{user_data.get('firstName', '')} {user_data.get('lastName', '')}".strip(),
            "provider_id": user_data["id"],
            "access_token": access_token,
            "extra_data": {**user_data, "emailAddress": email},
        }
import os
from google.oauth2 import id_token
from google.auth.transport import requests
import jwt  # Only used for safe header/claim inspection (not verification)

# Load from environment
GOOGLE_CLIENT_ID = os.getenv("GOOGLE_CLIENT_ID")
FIREBASE_PROJECT_ID = os.getenv("FIREBASE_PROJECT_ID")

def verify_google_id_token(token: str) -> dict:
    """
    Verifies an ID token, auto-detecting whether it's a Firebase or Google OAuth2 token.
    
    Returns:
        dict: Decoded token payload if valid.
    
    Raises:
        ValueError: If token is invalid or verification fails.
    """
    if not token:
        raise ValueError("Token is empty or missing")

    # Safely decode header and payload WITHOUT verification to inspect 'iss'
    try:
        unverified_header = jwt.get_unverified_header(token)
        unverified_payload = jwt.decode(token, options={"verify_signature": False})
    except Exception as e:
        raise ValueError(f"Invalid token format: {str(e)}")

    iss = unverified_payload.get("iss")
    aud = unverified_payload.get("aud")

    if not iss:
        raise ValueError("Token missing 'iss' (issuer) claim")

    # Firebase tokens have issuer: https://securetoken.google.com/<PROJECT_ID>
    if iss.startswith("https://securetoken.google.com/"):
        if not FIREBASE_PROJECT_ID:
            raise ValueError("FIREBASE_PROJECT_ID is not set, cannot verify Firebase token")
        
        expected_issuer = f"https://securetoken.google.com/{FIREBASE_PROJECT_ID}"
        if iss != expected_issuer:
            raise ValueError(f"Invalid Firebase issuer. Expected: {expected_issuer}, Got: {iss}")
        
        if aud != FIREBASE_PROJECT_ID:
            raise ValueError(f"Firebase token audience mismatch. Expected: {FIREBASE_PROJECT_ID}, Got: {aud}")

        # Verify as Firebase token
        try:
            return id_token.verify_firebase_token(
                token,
                requests.Request(),
                FIREBASE_PROJECT_ID
            )
        except Exception as e:
            raise ValueError(f"Firebase token verification failed: {str(e)}")

    # Google OAuth2 tokens have issuer: https://accounts.google.com or https://oauth2.googleapis.com/token
    elif iss in ("https://accounts.google.com", "https://oauth2.googleapis.com/token"):
        if not GOOGLE_CLIENT_ID:
            raise ValueError("GOOGLE_CLIENT_ID is not set, cannot verify Google OAuth token")
        
        if aud != GOOGLE_CLIENT_ID:
            raise ValueError(f"Google token audience mismatch. Expected: {GOOGLE_CLIENT_ID}, Got: {aud}")

        # Verify as Google OAuth2 token
        try:
            return id_token.verify_oauth2_token(
                token,
                requests.Request(),
                GOOGLE_CLIENT_ID
            )
        except Exception as e:
            raise ValueError(f"Google OAuth token verification failed: {str(e)}")

    else:
        raise ValueError(f"Unsupported token issuer: {iss}")
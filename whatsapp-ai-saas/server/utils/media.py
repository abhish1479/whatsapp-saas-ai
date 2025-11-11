
import base64
import os
import shutil
from fastapi import UploadFile
import requests
from settings import settings
from typing import Dict, Any
import httpx  # Added for making HTTP requests
import mimetypes

BASE_URL = "https://login.mymobiforce.com/IntegrationHubTestAPI/api/BrandQrCodeController"

def save_image(file: UploadFile) -> str:
    # save into MEDIA_DIR and return public URL
    filename = file.filename
    dest_path = os.path.join(settings.MEDIA_DIR, filename)
    # avoid overwrite: add suffix if exists
    base, ext = os.path.splitext(filename)
    i = 1
    while os.path.exists(dest_path):
        filename = f"{base}_{i}{ext}"
        dest_path = os.path.join(settings.MEDIA_DIR, filename)
        i += 1
    with open(dest_path, "wb") as f:
        shutil.copyfileobj(file.file, f)
    return f"{settings.BASE_URL}/media/{filename}"

def to_data_url(binary: bytes, content_type: str) -> str:
    """Convert binary data to data URL format for OpenAI."""
    b64 = base64.b64encode(binary).decode("utf-8")
    return f"data:{content_type};base64,{b64}"


def url_to_bytes(url: str, timeout: int = 30) -> bytes | None:
    try:
        response = requests.get(url, timeout=timeout)
        response.raise_for_status() # Raises an HTTPError for bad responses (4xx or 5xx)
        return response.content
    except requests.exceptions.RequestException as e:
        print(f"[ERROR] Failed to fetch {url}: {e}") # Optional: Log the error
        return None
    


# --- 2. Utility Functions ---

def get_media_type(key: str) -> str:
    """
    Infers the standard MIME type based on the file extension
    using Python's mimetypes library.
    """
    # --- SIMPLIFIED: Use mimetypes to guess type ---
    mimetype, _ = mimetypes.guess_type(key)
    
    # Return the guessed type, or a default for unknown types
    return mimetype or "application/octet-stream"


# --- 3. API Call Functions ---

async def upload_file_cloud(key: str, base64_string: str) -> Dict[str, Any]:
    """
    Calls the external Azure upload API with the provided key and Base64 string.
    """
    upload_url = f"{BASE_URL}/UplaodFiletoAzurekenstar"
    
    # Construct the payload as specified in the cURL command
    payload = {
        "Key": key,
        "Base64String": base64_string
    }
    
    headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }

    try:
        # Use httpx.AsyncClient for async requests
        async with httpx.AsyncClient() as client:
            print(f"Attempting to upload '{key}' to {upload_url}...")
            response = await client.post(upload_url, json=payload, headers=headers)
            
            # Check for HTTP errors (4xx or 5xx)
            response.raise_for_status() 
            
            # Assuming the remote API returns JSON on success
            print(f"Upload successful for '{key}'. Response: {response.json()}")
            return {"success": True, "data": response.json()}
        
    except httpx.HTTPStatusError as e:
        print(f"HTTP error uploading '{key}': {e.response.status_code} {e.response.text}")
        return {"success": False, "error": f"HTTP error: {e.response.status_code}", "details": e.response.text}
    except httpx.RequestError as e:
        print(f"Network error uploading '{key}': {e}")
        return {"success": False, "error": f"Network error: {e}"}
    except Exception as e:
        print(f"An unexpected error occurred during upload: {e}")
        return {"success": False, "error": f"Unexpected error: {e}"}


async def download_file(key: str) -> Dict[str, Any]:
    download_url = f"{BASE_URL}/DowloadFileFromAzurekenstar"
    params = {"key": key}

    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            print(f"Attempting to download '{key}' from {download_url}...")
            response = await client.post(download_url, params=params, data=None)
            response.raise_for_status()

            print(f"Download successful for '{key}', {len(response.content)} bytes.")
            return {
                "success": True,
                "data": response.content,  # bytes
                "filename": key,
                "size_bytes": len(response.content)
            }

    except httpx.HTTPStatusError as e:
        error_msg = "File not found" if e.response.status_code == 404 else f"HTTP {e.response.status_code}"
        return {"success": False, "error": error_msg, "details": e.response.text}
    except Exception as e:
        return {"success": False, "error": "Network or unexpected error", "details": str(e)}
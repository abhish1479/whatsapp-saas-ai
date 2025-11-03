
import base64
import os
import shutil
from fastapi import UploadFile
import requests
from settings import settings

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
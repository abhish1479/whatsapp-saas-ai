
import os
import shutil
from fastapi import UploadFile
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
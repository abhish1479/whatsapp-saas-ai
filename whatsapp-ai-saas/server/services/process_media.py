from typing import Optional
from utils.system_prompts import IMAGE_PROMPT
from utils.image_analyzer import analyze_image_from_bytes
from utils.media import url_to_bytes
from utils.sessions import append_user
# from utils.hinglish_stt import transcribe_hinglish


async def process_media_message(sender, media_type, media_url, caption):
    """Process media messages (images, audio)"""
    try:
        if media_type == 'image':
            img_bytes = url_to_bytes(media_url)
            if img_bytes:
                await process_media_files(sender, caption, image_bytes=img_bytes)
        
        if media_type == 'audio':
            audio_bytes = url_to_bytes(media_url)
            if audio_bytes and len(audio_bytes) >= 10:
               await process_media_files(sender, caption, audio_bytes=audio_bytes)

    except Exception as e:
        print(f"[MEDIA] Error processing {media_type}: {e}")
        await append_user(sender, caption or f"{media_type.capitalize()} received")


async def process_media_files(sender, caption, image_bytes: Optional[bytes] = None, audio_bytes: Optional[bytes] = None):
    """Process media messages (images, audio)"""
    try:

        # Determine content type based on available media
        has_image = image_bytes is not None
        has_audio = audio_bytes is not None
        if has_image:
            print("[BACKGROUND] Processing image content")
            response_text = await analyze_image_from_bytes(image_bytes, user_prompt=IMAGE_PROMPT)
            await append_user(sender, response_text)

        # if has_audio and len(audio_bytes) >= 10:
        #         transcribed_text = transcribe_hinglish(audio_bytes)
        #         if transcribed_text:
        #             await append_user(sender, transcribed_text)
        #         else:
        #             await append_user(sender, caption or "Voice message received")
        
    except Exception as e:
        print(f"[MEDIA] Error processing media: {e}")
        await append_user(sender, caption or "Media received")

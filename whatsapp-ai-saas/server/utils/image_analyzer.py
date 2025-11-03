import asyncio
import base64
from services.llm import client
# from utils.log import append_usage

async def analyze_image_from_bytes(image_bytes: bytes, user_prompt: str = "What is this issue?") -> str:
    """Analyze an image from bytes using GPT-4 Vision"""
    
    # Encode image bytes to base64
    base64_img = base64.b64encode(image_bytes).decode("utf-8")
    
    # Create image URL with base64 data
    image_url = {"url": f"data:image/jpeg;base64,{base64_img}"}
    
    response = await client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": user_prompt},
                    {"type": "image_url", "image_url": image_url}
                ]
            }
        ],
        max_tokens=500,
    )

    usage = getattr(response, "usage", None)
    # asyncio.create_task(append_usage("Image", usage.get("total_tokens", 0), "token"))

    return response.choices[0].message.content
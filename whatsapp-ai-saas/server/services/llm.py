import os, logging
from typing import Dict, Any, List

# Provider selection
PROVIDER = os.getenv("LLM_PROVIDER", "openai").lower()
MODEL = os.getenv("LLM_MODEL", "gpt-4o-mini")
TEMPERATURE = float(os.getenv("LLM_TEMPERATURE", "0.3"))

# --- OpenAI ---
if PROVIDER == "openai":
    import openai
    openai.api_key = os.getenv("OPENAI_API_KEY")

# --- Anthropic ---
elif PROVIDER == "anthropic":
    from anthropic import AsyncAnthropic
    anthropic_client = AsyncAnthropic(api_key=os.getenv("ANTHROPIC_API_KEY"))
    MODEL = os.getenv("LLM_MODEL", "claude-3-haiku-20240307")

# --- Gemini (Google AI Studio) ---
elif PROVIDER == "gemini":
    import google.generativeai as genai
    genai.configure(api_key=os.getenv("GEMINI_API_KEY"))
    MODEL = os.getenv("LLM_MODEL", "gemini-1.5-flash")

# --- Ollama (local) ---
elif PROVIDER == "ollama":
    import httpx
    OLLAMA_URL = os.getenv("OLLAMA_URL", "http://localhost:11434")
    MODEL = os.getenv("LLM_MODEL", "llama3")

# --- default log ---
logger = logging.getLogger(__name__)


def _build_prompt(tenant_id: str, query: str, docs: Dict[str, Any]) -> str:
    context_texts: List[str] = []
    if docs and "documents" in docs:
        for dlist in docs["documents"]:
            context_texts.extend(dlist)
    context = "\n".join(context_texts[:5])
    return f"""
You are a helpful WhatsApp agent for tenant {tenant_id}.
User asked: {query}

Business knowledge:
{context if context else "No documents available."}

Rules:
- If no relevant knowledge, say "I will connect you with the business owner."
- Be concise, friendly, and professional.
"""


async def generate_reply(tenant_id: str, query: str, docs: Dict[str, Any]) -> str:
    try:
        prompt = _build_prompt(tenant_id, query, docs)

        if PROVIDER == "openai":
            resp = await openai.ChatCompletion.acreate(
                model=MODEL,
                messages=[{"role": "system", "content": "You are a WhatsApp business assistant."},
                          {"role": "user", "content": prompt}],
                temperature=TEMPERATURE,
                max_tokens=300,
            )
            return resp["choices"][0]["message"]["content"].strip()

        elif PROVIDER == "anthropic":
            resp = await anthropic_client.messages.create(
                model=MODEL,
                max_tokens=300,
                temperature=TEMPERATURE,
                messages=[{"role": "user", "content": prompt}],
            )
            return resp.content[0].text.strip()

        elif PROVIDER == "gemini":
            model = genai.GenerativeModel(MODEL)
            resp = model.generate_content(prompt)
            return resp.text.strip()

        elif PROVIDER == "ollama":
            async with httpx.AsyncClient() as client:
                r = await client.post(f"{OLLAMA_URL}/api/chat", json={
                    "model": MODEL,
                    "messages": [{"role": "user", "content": prompt}],
                    "options": {"temperature": TEMPERATURE},
                }, timeout=60)
                data = r.json()
                return data.get("message", {}).get("content", "No response").strip()

        else:
            return "No LLM provider configured."

    except Exception as e:
        logger.exception(f"[LLM] Failed for tenant={tenant_id}: {e}")
        return "Sorry, I'm facing issues. Please contact the business owner directly."

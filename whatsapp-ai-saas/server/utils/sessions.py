import time
from collections import defaultdict
from typing import Optional
from utils.enums import Role
from services.rag import rag

SESSION_EXPIRY_SECONDS = 1800  # 30 minutes

# In-memory session stores
user_sessions = defaultdict(list)  # {sender: [messages]}
last_message_time = {}


def System_Prompt(tenant_id):
    return "You are a helpful assistant."
    


def get_history(sender: str,tenant_id: Optional[int] = None):
    now = time.time()
    if sender in user_sessions:
        if now - last_message_time.get(sender, 0) > SESSION_EXPIRY_SECONDS:
            user_sessions[sender] = []  # expired
    if not user_sessions[sender]:
        if Role.TECHNICAN.value in sender:
            user_sessions[sender].append({"role": "system", "content": System_Prompt(tenant_id)})
        else:
            user_sessions[sender].append({"role": "system", "content": System_Prompt(tenant_id)})
    last_message_time[sender] = now
    return user_sessions[sender]


async def append_user(sender: str, content , tenant_id: Optional[int] = None):
    get_history(sender,tenant_id).append({"role": "user", "content": content})
    rag_context = ""
    if content and tenant_id:
        rag_results = await rag.search(tenant_id=tenant_id, query=content, k=3)
        if rag_results:
            snippets = [
                    f"• {r['text']}" for r in rag_results[:3]
                ]
            rag_context = "\n".join(snippets)
        get_history(sender,tenant_id).append({"role": "system", "content": rag_context})       


def append_assistant(sender: str, content: str):
    get_history(sender).append({"role": "assistant", "content": content})
    last_message_time[sender] = time.time()


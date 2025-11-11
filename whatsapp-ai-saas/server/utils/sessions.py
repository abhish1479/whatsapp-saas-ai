import json
import time
from collections import defaultdict
from typing import Optional

from fastapi import logger
from fastapi.responses import JSONResponse
from utils.enums import Role
from services.rag import rag
from deps import get_db_session
from models import Template, BusinessProfile, AgentConfiguration, Workflow

SESSION_EXPIRY_SECONDS = 1800  # 30 minutes

# In-memory session stores
user_sessions = defaultdict(list)  # {sender: [messages]}
last_message_time = {}


def safe_to_dict(obj):
    """Safely converts a SQLAlchemy model instance to a dictionary, handling None."""
    if obj is None:
        return {}
    # Assuming models have a dict-like interface or we convert manually,
    # and excluding private attributes starting with '_'.
    return {c.name: getattr(obj, c.name) for c in obj.__table__.columns if not c.name.startswith('_')}

def System_Prompt(tenant_id: int) -> str:
    """
    Constructs the dynamic System Prompt for the LLM based on tenant configuration.
    """
    business_profile = {}
    agent_config = {}
    workflow = {}
    template = {}

    try:
        # Use the reusable context manager to acquire a database session
        with get_db_session() as db:
            
            # 1. Fetch Business Profile
            bp = db.query(BusinessProfile).filter(BusinessProfile.tenant_id == tenant_id).first()
            business_profile = safe_to_dict(bp)
                            
            # 2. Fetch Agent Configuration
            ac = db.query(AgentConfiguration).filter(AgentConfiguration.tenant_id == tenant_id).first()
            agent_config = safe_to_dict(ac)
        
            # 3. Fetch Workflow
            wk = db.query(Workflow).filter(Workflow.tenant_id == tenant_id).first()
            workflow = safe_to_dict(wk)
                            
            # 4. Fetch Default Template (assuming 'Template' model exists)
            tm = db.query(Template).filter(Template.tenant_id == tenant_id).first()
            template = safe_to_dict(tm)
            
    except Exception as e:
        logger.error(f"Error fetching tenant configuration for system prompt (tenant_id={tenant_id}): {e}")
        # All configuration dictionaries will remain empty ({}) on failure

    # Format the data into a concise JSON string (or near-JSON format for readability)
    config_data = {
        "business": business_profile,
        "agent_config": agent_config,
        "workflow": workflow,
        "template": template
    }
    
    # Use json.dumps to convert the Python dict to a string. 
    # Use 'indent=None, separators=(',', ':')' for conciseness.
    config_str = json.dumps(config_data, default=str, indent=None, separators=(',', ':'))

    # Construct the final, highly defined system prompt for the LLM
    prompt = f"""
You are a highly efficient and professional WhatsApp Chat Agent. Your responses must be guided strictly by the provided configuration.

**ROLE & CONFIGURATION (JSON):**
{config_str}

**INSTRUCTIONS:**
1. **Persona:** Adopt the tone and business information from the 'business' and 'agent_config' sections.
2. **Workflow:** If the user's intent matches a step in the 'workflow' (e.g., product inquiry), prioritize using the information specified there.
3. **Template:** Use the content from the 'template' section for initial greeting or standard replies when appropriate.
4. **Be Concise:** Respond directly and professionally. Avoid acknowledging the configuration data directly unless asked.
"""
    return prompt.strip()
    


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


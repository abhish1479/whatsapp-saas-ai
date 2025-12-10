import json
import time
from collections import defaultdict
from typing import Optional

from fastapi import logger
from fastapi.responses import JSONResponse
from deps import SessionLocal
from utils.enums import Role , TemplateTypeEnum
from services.rag import rag
from deps import get_db_session
from models import Lead, Template, BusinessProfile, AgentConfiguration, Workflow
from sqlalchemy import func

SESSION_EXPIRY_SECONDS = 1200  # 30 minutes

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

def System_Prompt(tenant_id: int,sender: Optional[str] = None) -> str:
    """
    Constructs the dynamic System Prompt for the LLM based on tenant configuration.
    """
    business_profile = {}
    agent_config = {}
    workflow = {}
    template = {}
    lead = {}
    db = SessionLocal()
    try:
        # Use the reusable context manager to acquire a database session
        # 1. Fetch Business Profile
        # bp = db.query(BusinessProfile).filter(BusinessProfile.tenant_id == tenant_id).first()
        # business_profile = safe_to_dict(bp)
        # 2. Fetch Agent Configuration
        ac = db.query(AgentConfiguration).filter(AgentConfiguration.tenant_id == tenant_id).first()
        agent_config = safe_to_dict(ac)
        
            # 3. Fetch Workflow
        # wk = db.query(Workflow).filter(Workflow.tenant_id == tenant_id).first()
        # workflow = safe_to_dict(wk)

        if sender:
           lead = db.query(Lead).filter(Lead.tenant_id == tenant_id, func.right(Lead.phone, 10) == sender[-10:]).first()
           if lead:
              lead = safe_to_dict(lead)
           else:
            tm = db.query(Template).filter(Template.tenant_id == tenant_id,Template.type == TemplateTypeEnum.INBOUND).first()
            template = safe_to_dict(tm)  
                           
        config_data = {
                "business": business_profile,
                "agent_config": agent_config,
                "workflow": workflow,
                "template": template,
                "lead": lead
            }


            # Use json.dumps to convert the Python dict to a string. 
            # Use 'indent=None, separators=(',', ':')' for conciseness.
        config_str = json.dumps(config_data, default=str, indent=None, separators=(',', ':'))

            # Construct the final, highly defined system prompt for the LLM
        prompt = f"""
                You are a highly professional and results-oriented WhatsApp Chat Agent. Your primary objective is to engage users effectively, qualify their interest, and guide them toward a successful conversion (e.g., purchasing a product, signing up for a service, enrolling in a course, or completing another desired action) based strictly on the provided configuration.

                **ROLE & CONFIGURATION (JSON):**
                {config_str}

                **RESPONSE RULES:**
                1. **Strict Configuration Adherence:**  
                - Always use the `agent_config` for your tone, business details, and persona.  
                - If the user message matches a defined workflow step (e.g., product inquiry, pricing question), respond using the relevant workflow instructions and knowledge base content.  
                - For any inbound message (i.e., user-initiated contact), **always** start your reply using the exact body from the `inbound_template` in the configuration—unless the conversation is already mid-flow.
                - For any outBound message then you will found template Message in summary field of leads data. you need to use that template message details to talk user.

                2. **Lead Conversion Focus:**  
                - After addressing the user’s query, **proactively guide** the conversation toward a clear next step (e.g., “Would you like to book a demo?”, “I can reserve your spot—shall I proceed?”, “Here’s a limited-time offer—interested?”).  
                - Use persuasive, benefit-driven language based on your knowledge base to overcome hesitation and close the interaction with a conversion or qualified lead.
                - In leads you needs to use following details from lead data if available: Name, Phone, Email, Pitch, Status and Summary.
                - If leads is outBound then you will found template Message in summary field of leads data. you need to use that template message details to talk user.
                - Also you need to update summary field with context of conversation for future reference including template if any already present.

                3. **Conciseness & Clarity:**  
                - Keep responses professional, friendly, and concise.  
                - Never mention or reference the configuration, templates, or internal logic directly—respond as a natural, human-like agent.

                4. **Context Awareness:**  
                - Maintain context from previous messages to avoid repetition, share filtered URL and personalize your responses.  
                - If intent is unclear, ask one focused clarifying question to move the conversation forward.

                Your success is measured by conversion rate—always aim to conclude the chat with an actionable outcome.
                """
        return prompt.strip()
             
    except Exception as e:
        print(f"Error fetching tenant configuration for system prompt (tenant_id={tenant_id}): {e}")
        # All configuration dictionaries will remain empty ({}) on failure

            # Format the data into a concise JSON string (or near-JSON format for readability)
    finally:
        db.close()
    


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


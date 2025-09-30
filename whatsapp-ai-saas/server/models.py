
import uuid
from sqlalchemy import UUID, Column, Index, Integer, Numeric, String, Boolean, ForeignKey, Text, DateTime, JSON, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base
from utils.enums import Onboarding

class Tenant(Base):
    __tablename__ = "tenants"
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False, unique=True)
    plan = Column(String, default="starter")
    created_at = Column(DateTime, server_default=func.now())

class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
    email = Column(String, unique=True, nullable=False)
    password_hash = Column(String, nullable=False)
    role = Column(String, default="owner")
    onboarding_process = Column(String, default=Onboarding.INPROCESS) # InProgress|Completed
    identities = relationship("Identity", back_populates="user", cascade="all, delete-orphan")
    created_at = Column(DateTime, server_default=func.now())

class Identity(Base):
    __tablename__ = "identities"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    provider = Column(String, nullable=False)  # e.g., "google", "email"
    provider_id = Column(String, nullable=False)  # Google's sub, Twitter's id
    email = Column(String, nullable=True)
    access_token = Column(String, nullable=True)
    refresh_token = Column(String, nullable=True)
    expires_at = Column(DateTime, nullable=True)
    extra_data = Column(JSON, nullable=True)  # Store full profile

    user = relationship("User", back_populates="identities")

    __table_args__ = (
        UniqueConstraint('provider', 'provider_id', name='uq_provider_provider_id'),
        UniqueConstraint('user_id', 'email', name='uq_user_email_if_provided'),
    )

class Number(Base):
    __tablename__ = "numbers"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
    provider = Column(String)
    wa_phone = Column(String)
    wa_id = Column(String)
    status = Column(String, default="pending")
    created_at = Column(DateTime, server_default=func.now())

class Lead(Base):
    __tablename__ = "leads"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
    name = Column(String)
    phone = Column(String, index=True)
    source = Column(String)
    notes = Column(Text)
    status = Column(String, default="new")
    created_at = Column(DateTime, server_default=func.now())

class Conversation(Base):
    __tablename__ = "conversations"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, nullable=False)
    phone = Column(String, index=True)
    last_msg_at = Column(DateTime)
    state = Column(JSON, default={})
    created_at = Column(DateTime, server_default=func.now())

class Message(Base):
    __tablename__ = "messages"
    id = Column(Integer, primary_key=True)
    conversation_id = Column(Integer, ForeignKey("conversations.id"))
    direction = Column(String) # in|out
    text = Column(Text)
    meta = Column(JSON, default={})
    cost_credits = Column(Integer, default=0)
    created_at = Column(DateTime, server_default=func.now())

class Wallet(Base):
    __tablename__ = "wallets"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), unique=True, nullable=False)
    credits_balance = Column(Integer, default=0)

class WalletTx(Base):
    __tablename__ = "wallet_tx"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, nullable=False)
    delta = Column(Integer, nullable=False)
    reason = Column(String, nullable=False)
    ref_id = Column(String)
    created_at = Column(DateTime, server_default=func.now())

class Template(Base):
    __tablename__ = "templates"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, nullable=False)
    name = Column(String, nullable=False)
    language = Column(String, default="en")
    category = Column(String, default="MARKETING")
    body = Column(Text, nullable=False)
    status = Column(String, default="draft")



class BusinessProfile(Base):
    __tablename__ = "business_profiles"

    tenant_id = Column(String(64), primary_key=True)
    business_name = Column(Text, nullable=False)
    owner_phone = Column(Text, nullable=False)
    language = Column(String(8), nullable=False, default="en")
    business_type = Column(String(16))
    is_active = Column(Boolean, nullable=False, default=False)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())

# -------------------------------
# Items
# -------------------------------
class Item(Base):
    __tablename__ = "items"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    tenant_id = Column(String(64), nullable=False)
    name = Column(Text, nullable=False)
    price = Column(Numeric(precision=10, scale=2), nullable=False, default=0)
    description = Column(Text)
    image_url = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

    # Optional: Index for performance (matches your SQL index)
    __table_args__ = (Index('idx_items_tenant', 'tenant_id'),)


# -------------------------------
# Workflows
# -------------------------------
class Workflow(Base):
    __tablename__ = "workflows"

    tenant_id = Column(String(64), primary_key=True)
    template = Column(Text, nullable=False)
    ask_name = Column(Boolean, nullable=False, default=True)
    ask_location = Column(Boolean, nullable=False, default=False)
    offer_payment = Column(Boolean, nullable=False, default=True)
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())


# -------------------------------
# Payments
# -------------------------------
class Payment(Base):
    __tablename__ = "payments"

    tenant_id = Column(String(64), primary_key=True)
    upi_id = Column(Text)
    bank_details = Column(Text)
    checkout_link = Column(Text)
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())


# -------------------------------
# Web Ingest Requests
# -------------------------------
class WebIngestRequest(Base):
    __tablename__ = "web_ingest_requests"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    tenant_id = Column(String(64), nullable=False)
    url = Column(Text, nullable=False)
    status = Column(String(16), nullable=False, default="queued")
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

class AgentConfiguration(Base):
    __tablename__ = "agent_configurations"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False, index=True)
    agent_name = Column(String(100), nullable=False)  # e.g., "SupportBot", "SalesAgent"
    status = Column(String(20), default="active", nullable=False)  # active, inactive, paused
    preferred_languages = Column(Text, nullable=False)  # comma-separated: "en,es,fr" — stored as string for simplicity
    conversation_tone = Column(String(50), default="professional")  # professional, casual, friendly, formal
    incoming_voice_message_enabled = Column(Boolean, default=True)  # allow incoming voice messages
    outgoing_voice_message_enabled = Column(Boolean, default=True)  # allow outgoing voice messages
    incoming_media_message_enabled = Column(Boolean, default=True)  # allow images, docs, etc.
    outgoing_media_message_enabled = Column(Boolean, default=True)
    image_analyzer_enabled = Column(Boolean, default=False)  # enable AI image analysis (OCR, object detection)

    tenant = relationship("Tenant")

    __table_args__ = (
        Index('idx_tenant_agent', 'tenant_id', 'agent_name', unique=True),
    )
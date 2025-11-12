
import uuid
from sqlalchemy import UUID, Column, Enum, Float, Index, Integer, Numeric, String, Boolean, ForeignKey, Text, DateTime, JSON, UniqueConstraint,BigInteger
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base
from utils.enums import Onboarding, ProcessingStatusEnum, SourceTypeEnum , TemplateStatusEnum , TemplateTypeEnum

class Timestamp:
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(
        DateTime(timezone=True),
        server_default=func.now(),
        onupdate=func.now(),
        nullable=False
    )
class Tenant(Base):
    __tablename__ = "tenants"
    id = Column(Integer, primary_key=True)
    name = Column(String, nullable=False)
    plan = Column(String, default="starter")
    rag_enabled = Column(Boolean, default=False)
    rag_updated_at = Column(DateTime)
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

# class Lead(Base):
#     __tablename__ = "leads"
#     id = Column(Integer, primary_key=True)
#     tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
#     name = Column(String)
#     phone = Column(String, index=True)
#     source = Column(String)
#     notes = Column(Text)
#     status = Column(String, default="new")
#     created_at = Column(DateTime, server_default=func.now())

class Conversation(Base):
    __tablename__ = "conversations"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
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
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
    delta = Column(Integer, nullable=False)
    reason = Column(String, nullable=False)
    ref_id = Column(String)
    created_at = Column(DateTime, server_default=func.now())

class Template(Timestamp,Base):
    __tablename__ = "templates"
    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
    name = Column(String, nullable=False)
    language = Column(String, default="en")
    category = Column(String, default="MARKETING")
    body = Column(Text, nullable=False)
    status = Column(Enum(TemplateStatusEnum), nullable=False, default=TemplateStatusEnum.DRAFT, index=True)
    type = Column(Enum(TemplateTypeEnum), nullable=False, index=True)


class BusinessProfile(Base):
    __tablename__ = "business_profiles"

    tenant_id = Column(Integer, ForeignKey("tenants.id", ondelete="CASCADE"),
                       primary_key=True, unique=True)
    business_name = Column(Text, nullable=False)
    # CHANGED:
    business_whatsapp = Column(Text, nullable=False)   # was owner_phone
    personal_number   = Column(Text, nullable=True)    # NEW
    language      = Column(String(8), nullable=False, default="en")
    business_type = Column(String(16))
    description = Column(Text)
    custom_business_type = Column(Text)
    business_category = Column(Text)
    is_active     = Column(Boolean, nullable=False, default=False)
    created_at    = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at    = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())


# -------------------------------
# Items
# -------------------------------
class Item(Base):
    __tablename__ = "items"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
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

    id = Column(BigInteger, primary_key=True, index=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
    template = Column(Text, nullable=False)
    ask_name = Column(Boolean, nullable=False, default=True)
    ask_location = Column(Boolean, nullable=False, default=False)
    offer_payment = Column(Boolean, nullable=False, default=True)
    qr_image_url = Column(Text, nullable=True)  # URL to QR code image
    upi_id = Column(Text, nullable=True)        # e.g., "user@upi"
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())


# -------------------------------
# Payments
# -------------------------------
class Payment(Base):
    __tablename__ = "payments"

    tenant_id = Column(Integer,ForeignKey("tenants.id", ondelete="CASCADE"),primary_key=True, unique=True  )
    upi_id = Column(Text)
    bank_details = Column(Text)
    checkout_link = Column(Text)
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())


# -------------------------------
# Web Ingest Requests
# -------------------------------
class WebIngestRequest(Base):
    __tablename__ = "web_ingest_requests"

    id = Column(Integer, primary_key=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id"), nullable=False)
    status = Column(String(16), nullable=False, default="queued")
    url = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())

class AgentConfiguration(Base):
    __tablename__ = "agent_configurations"
    
    id = Column(Integer, primary_key=True, index=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False, index=True)
    agent_name = Column(String(100), nullable=False)  # e.g., "SupportBot", "SalesAgent"
    agent_image = Column(String(250), nullable=True)  # URL to avatar image
    status = Column(String(20), default="active", nullable=False)  # active, inactive, paused
    preferred_languages = Column(Text, nullable=False)  # comma-separated: "en,es,fr" — stored as string for simplicity
    conversation_tone = Column(String(50), default="professional")  # professional, casual, friendly, formal
    incoming_voice_message_enabled = Column(Boolean, default=True)  # allow incoming voice messages
    outgoing_voice_message_enabled = Column(Boolean, default=True)  # allow outgoing voice messages
    incoming_media_message_enabled = Column(Boolean, default=True)  # allow images, docs, etc.
    outgoing_media_message_enabled = Column(Boolean, default=True)
    image_analyzer_enabled = Column(Boolean, default=False)  # enable AI image analysis (OCR, object detection)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    tenant = relationship("Tenant")

    __table_args__ = (
        Index('idx_tenant_agent', 'tenant_id', 'agent_name', unique=True),
    )


class Kyc(Base):
    __tablename__ = "kyc"

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False, index=True)
    aadhaar_number = Column(String(12), unique=True, nullable=False)  # 12-digit numeric
    pan_number = Column(String(10), unique=True, nullable=False)      # 10-char alphanumeric
    status = Column(String(20), default="pending", nullable=False)    # pending, verified, rejected
    document_image_url = Column(String(512))                          # optional: selfie + doc photo URL
    verified_at = Column(DateTime, nullable=True)
    rejected_reason = Column(String(512), nullable=True)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User")
    tenant = relationship("Tenant")

    __table_args__ = (
        # Ensure no duplicate Aadhaar or PAN across tenants
        UniqueConstraint('aadhaar_number', name='uq_kyc_aadhaar'),
        UniqueConstraint('pan_number', name='uq_kyc_pan'),
    )


class SubscriptionPlan(Base):
    __tablename__ = "subscription_plans"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(50), nullable=False, unique=True)
    
    # ✅ Actual total price user pays for the full duration
    price = Column(Float, nullable=False)  # e.g., 999, 19999, 39999

    # ✅ Normalized price per month (for easy comparison)
    price_per_month = Column(Float, nullable=False)  # e.g., 999, 1666.58, 1999.92

    credits = Column(Integer, nullable=False)
    duration_days = Column(Integer, nullable=False)  # e.g., 30, 365, 180
    billing_cycle = Column(String(20), nullable=True)  # e.g., "month", "year", "half-year"

    features = Column(Text, nullable=False)          # JSON string
    is_popular = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    def __repr__(self):
        return f"<SubscriptionPlan(name='{self.name}', price={self.price}, duration={self.duration_days}d)>"
    


class BusinessCatalog(Base):
    __tablename__ = "business_catalog"

    id = Column(Integer, primary_key=True, autoincrement=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False, index=True)
    item_type = Column(String)
    name = Column(Text, nullable=False)
    description = Column(Text)
    category = Column(Text)
    price = Column(Numeric)
    discount = Column(Numeric)
    currency = Column(Text)
    source_url = Column(Text)
    image_url = Column(Text)
    created_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now())
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())

## Added Leads, Campaign and related models
class Lead(Base):
    __tablename__ = "leads"
    id = Column(BigInteger, primary_key=True, index=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(Text, nullable=True)
    phone = Column(Text, nullable=False)
    email = Column(Text, nullable=True)
    tags = Column(JSON, default=list)
    product_service = Column(Text, nullable=True)
    pitch = Column(Text, nullable=True)
    workflow_id = Column(BigInteger, ForeignKey("workflows.id"), nullable=True)
    status = Column(Text, default="New")
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())
    recipients = relationship("CampaignRecipient", back_populates="lead", lazy="selectin")

    __table_args__ = (
        UniqueConstraint("tenant_id", "phone", name="uq_tenant_phone"),
    )

# class Workflow(Base):
#     __tablename__ = "workflows"
#     id = Column(BigInteger, primary_key=True, index=True)
#     tenant_id = Column(BigInteger, index=True, nullable=False)
#     name = Column(Text, nullable=False)
#     json = Column(JSON, nullable=False, default=dict)
#     is_default = Column(Boolean, default=False)

class Campaign(Base):
    __tablename__ = "campaigns"
    id = Column(BigInteger, primary_key=True, index=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False, index=True)
    name = Column(Text, nullable=False)
    status = Column(Text, default="Draft")
    schedule_at = Column(DateTime(timezone=True), nullable=True)
    auto_schedule_json = Column(JSON, nullable=True)
    audience_filter_json = Column(JSON, nullable=True)
    template_id = Column(BigInteger, nullable=True)
    default_pitch = Column(Text, nullable=True)
    default_workflow_id = Column(BigInteger, ForeignKey("workflows.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())

    recipients = relationship("CampaignRecipient", back_populates="campaign", lazy="selectin")

class CampaignRecipient(Base):
    __tablename__ = "campaign_recipients"
    id = Column(BigInteger, primary_key=True, index=True)
    campaign_id = Column(BigInteger, ForeignKey("campaigns.id"), index=True, nullable=False)
    lead_id = Column(BigInteger, ForeignKey("leads.id"), index=True, nullable=False)
    send_status = Column(Text, default="Pending")
    send_at = Column(DateTime(timezone=True), nullable=True)
    deliver_at = Column(DateTime(timezone=True), nullable=True)
    read_at = Column(DateTime(timezone=True), nullable=True)
    reply_at = Column(DateTime(timezone=True), nullable=True)
    converted_at = Column(DateTime(timezone=True), nullable=True)
    error_code = Column(Text, nullable=True)
    credit_units = Column(Integer, default=0)
    meta = Column(JSON, default=dict)

    campaign = relationship("Campaign", back_populates="recipients")
    lead = relationship("Lead", back_populates="recipients")


class KnowledgeSource(Timestamp, Base):
    __tablename__ = "knowledge_sources"

    id = Column(BigInteger, primary_key=True, index=True)
    tenant_id = Column(Integer, ForeignKey("tenants.id", ondelete="CASCADE"), nullable=False, index=True)
    source_type = Column(Enum(SourceTypeEnum), nullable=False)
    name = Column(Text, nullable=False)
    source_uri = Column(Text, nullable=False)
    size_bytes = Column(BigInteger, nullable=True)
    summary = Column(Text, nullable=True)
    tags = Column(JSON, default=list)
    processing_status = Column(Enum(ProcessingStatusEnum), nullable=False, default=ProcessingStatusEnum.PENDING, index=True)
    processing_error = Column(Text, nullable=True)
    vector_chunk_count = Column(Integer, nullable=True, default=0)
    last_processed_at = Column(DateTime(timezone=True), nullable=True)

    def __repr__(self):
        return f"<KnowledgeSource(id={self.id}, name='{self.name}', status='{self.processing_status.value}')>"
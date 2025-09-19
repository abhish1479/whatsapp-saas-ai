
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Text, DateTime, JSON, UniqueConstraint
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from database import Base

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
    created_at = Column(DateTime, server_default=func.now())

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

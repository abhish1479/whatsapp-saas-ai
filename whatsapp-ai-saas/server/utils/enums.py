from enum import Enum
import enum


class Onboarding(str, Enum):
    INPROCESS = "InProcess"
    COMPLETED = "Completed"


class SocialProvider(str, Enum):
    GOOGLE = "google"
    FACEBOOK = "facebook"
    LINKEDIN = "linkedin"

class Role(str, Enum):
    TECHNICAN = "Field Engineer"  


class SourceTypeEnum(enum.Enum):
    FILE = "FILE"
    URL = "URL"

class ProcessingStatusEnum(str,enum.Enum):
    PENDING = "Pending"
    PROCESSING = "Processing"
    COMPLETED = "Completed"
    FAILED = "Failed"


class TemplateStatusEnum(str,enum.Enum):
    DRAFT = "Draft"
    SUBMITTED = "Submitted"
    ACTIVATED = "Activated"
    DEACTIVATED = "Deactivated"


class TemplateTypeEnum(str,enum.Enum):
    INBOUND = "Inbound"
    OUTBOUND = "Outbound"

class Channel(str,enum.Enum):
    WHATSAPP = "WhatsApp"
    VOICE = "Voice"
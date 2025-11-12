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

class ProcessingStatusEnum(enum.Enum):
    PENDING = "Pending"
    PROCESSING = "Processing"
    COMPLETED = "Completed"
    FAILED = "Failed"


class TemplateStatusEnum(enum.Enum):
    DRAFT = "Draft"
    SUBMITTED = "Submitted"
    ACTIVATED = "Activated"
    DEACTIVATED = "Deactivated"


class TemplateTypeEnum(enum.Enum):
    INBOUND = "Inbound"
    OUTBOUND = "Outbound"
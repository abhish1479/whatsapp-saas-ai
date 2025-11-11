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
    PENDING = "PENDING"
    PROCESSING = "PROCESSING"
    COMPLETED = "COMPLETED"
    FAILED = "FAILED"
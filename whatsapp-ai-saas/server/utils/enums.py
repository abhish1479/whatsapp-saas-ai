from enum import Enum


class Onboarding(str, Enum):
    INPROCESS = "InProcess"
    COMPLETED = "Completed"


class SocialProvider(str, Enum):
    GOOGLE = "google"
    FACEBOOK = "facebook"
    LINKEDIN = "linkedin"

class Role(str, Enum):
    TECHNICAN = "Field Engineer"  
from enum import StrEnum, unique

@unique
class Onboarding(StrEnum):
    INPROCESS = "InProcess"
    COMPLETED = "Completed"
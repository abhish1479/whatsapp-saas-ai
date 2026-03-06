# Example FastAPI Router Usage:
# 
from fastapi import APIRouter, Depends

from services.salesforce import SalesforceService

router = APIRouter()
salesforce_service = SalesforceService() # Instantiate as a singleton or via DI

@router.get("/api/pnr/{pnr_code}")
async def get_pnr(pnr_code: str):
    data = await salesforce_service.get_pnr_details(pnr_code)
    return data
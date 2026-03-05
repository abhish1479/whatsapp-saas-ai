import os
import httpx
from datetime import datetime, timedelta
from fastapi import HTTPException

class SalesforceService:
    def __init__(self):
        # In a real app, these should be loaded from environment variables (e.g., using python-dotenv or Pydantic BaseSettings)
        self.auth_url = "https://test.salesforce.com/services/oauth2/token"
        self.username = os.getenv("SF_USERNAME", "")
        self.password = os.getenv("SF_PASSWORD", "")
        self.client_id = os.getenv("SF_CLIENT_ID", "")
        self.client_secret = os.getenv("SF_CLIENT_SECRET", "")
        
        self.access_token = None
        self.instance_url = None
        self.token_expiry_time = None

    async def _get_new_token(self):
        """Fetches a new OAuth2 token from Salesforce and sets expiry to 15 minutes."""
        payload = {
            "grant_type": "password",
            "client_id": self.client_id,
            "client_secret": self.client_secret,
            "username": self.username,
            "password": self.password
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.post(self.auth_url, data=payload)
            
            if response.status_code != 200:
                raise HTTPException(status_code=500, detail="Failed to authenticate with Salesforce.")
            
            auth_data = response.json()
            self.access_token = auth_data.get("access_token")
            self.instance_url = auth_data.get("instance_url")
            
            # Cache the token for 15 minutes
            self.token_expiry_time = datetime.now() + timedelta(minutes=15)

    async def _ensure_valid_token(self):
        """Checks if the token exists and is valid. If not, fetches a new one."""
        if not self.access_token or not self.token_expiry_time or datetime.now() >= self.token_expiry_time:
            await self._get_new_token()

    async def get_pnr_details(self, pnr: str, retry: bool = True):
        """
        Fetches PNR details from Salesforce. 
        If a 401/Invalid Session error occurs, it fetches a new token and retries once.
        """
        await self._ensure_valid_token()
        
        endpoint = f"{self.instance_url}/services/apexrest/getOpportunityAndChildByPnr/{pnr}"
        headers = {
            "Authorization": f"Bearer {self.access_token}"
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.get(endpoint, headers=headers)
            
            # Salesforce often returns 401 or a 200/400 containing an 'INVALID_SESSION_ID' error code
            response_json = response.json()
            
            # Check for Salesforce specific session expiration
            is_session_expired = False
            if response.status_code == 401:
                is_session_expired = True
            elif isinstance(response_json, list) and len(response_json) > 0:
                if response_json[0].get("errorCode") == "INVALID_SESSION_ID":
                    is_session_expired = True
                    
            if is_session_expired:
                if retry:
                    # Force token refresh and retry exactly once
                    self.access_token = None 
                    return await self.get_pnr_details(pnr, retry=False)
                else:
                    raise HTTPException(status_code=401, detail="Salesforce session expired and retry failed.")
            
            if response.status_code != 200:
                raise HTTPException(status_code=response.status_code, detail="Error fetching data from Salesforce.")
            
            return self._clean_salesforce_response(response_json)

    def _clean_salesforce_response(self, raw_data: dict) -> dict:
        """
        Strips out Salesforce metadata ('attributes', URLs, relations) and 
        returns a clean, flattened JSON object with only required fields.
        """
        clean_data = {
            "pnr_details": {},
            "passengers": [],
            "baggage": [],
            "flights": []
        }

        # Clean Opportunity (PNR) Data
        opp = raw_data.get("opportunity", {})
        if opp:
            clean_data["pnr_details"] = {
                "id": opp.get("Id"),
                "pnr_no": opp.get("PNR_No__c"),
                "number_of_pax": opp.get("Number_of_Pax__c")
            }

        # Clean Passengers Data
        for pax in raw_data.get("passengers", []):
            clean_data["passengers"].append({
                "id": pax.get("Id"),
                "first_name": pax.get("First_Name__c"),
                "last_name": pax.get("Last_Name__c"),
                "email": pax.get("Email__c"),
                "dob": pax.get("Date_of_Birth__c")
            })

        # Clean Baggage Data
        for bag in raw_data.get("Brs_Baggage", []):
            clean_data["baggage"].append({
                "id": bag.get("Id"),
                "bag_number": bag.get("Name"),
                "status": bag.get("Bag_Status__c"),
                "routing": bag.get("Bag_Routing__c"),
                "passenger_name": bag.get("Passenger_Name__c")
            })

        # Clean Flight Data
        for flight_jun in raw_data.get("bookingFlights", []):
            flight = flight_jun.get("Flight__r", {})
            if flight:
                clean_data["flights"].append({
                    "id": flight.get("Id"),
                    "flight_no": flight.get("Flight_No__c"),
                    "flight_status": flight.get("Flight_Status__c"),
                    "departure_date": flight.get("Departure_Date__c"),
                    "arrival_time": flight.get("Arrival_Time__c"),
                    "std": flight.get("STD__c"),
                    "sta": flight.get("STA__c"),
                    "etd": flight.get("ETD__c")
                })

        return clean_data

# Example FastAPI Router Usage:
# 
# from fastapi import APIRouter, Depends
# 
# router = APIRouter()
# salesforce_service = SalesforceService() # Instantiate as a singleton or via DI
# 
# @router.get("/api/pnr/{pnr_code}")
# async def get_pnr(pnr_code: str):
#     data = await salesforce_service.get_pnr_details(pnr_code)
#     return data
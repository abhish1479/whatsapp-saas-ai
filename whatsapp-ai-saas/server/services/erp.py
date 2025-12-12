import requests
from settings import settings
import logging

logger = logging.getLogger(__name__)

class ERPNextClient:
    def __init__(self):
        # For Docker: Use host.docker.internal or the container IP
        # If ERPNext is also in Docker, use the service name
        self.base_url = settings.ERP_URL
        self.api_key = settings.ERP_ADMIN_API_KEY
        self.api_secret = settings.ERP_ADMIN_API_SECRET
        
        self.headers = {
            "Authorization": f"token {self.api_key}:{self.api_secret}",
            "Content-Type": "application/json"
        }

    def post(self, method: str, payload: dict, timeout=30):
        url = f"{self.base_url}/api/method/{method}"
        
        logger.info(f"ERPNext API Call: {url} with payload: {payload}")
        
        try:
            # Try different URLs for Docker compatibility
            urls_to_try = [
                url,
                url.replace("localhost", "host.docker.internal"),
                url.replace("localhost", "172.17.0.1")  # Default docker bridge
            ]
            
            last_exception = None
            for attempt_url in urls_to_try:
                try:
                    logger.info(f"Trying ERPNext URL: {attempt_url}")
                    response = requests.post(
                        attempt_url, 
                        json=payload, 
                        headers=self.headers, 
                        timeout=timeout
                    )
                    
                    logger.info(f"ERPNext Response Status: {response.status_code}")
                    
                    if response.status_code == 200:
                        try:
                            data = response.json()
                        except ValueError:
                            raise Exception(f"Invalid JSON response: {response.text}")
                        
                        if "exception" in data:
                            raise Exception(f"ERPNext Error: {data['exception']}")
                            
                        return data
                    else:
                        logger.warning(f"ERPNext returned status {response.status_code}")
                        
                except requests.exceptions.ConnectionError as e:
                    logger.warning(f"Connection failed for {attempt_url}: {str(e)}")
                    last_exception = e
                    continue
                except Exception as e:
                    logger.warning(f"Request failed for {attempt_url}: {str(e)}")
                    last_exception = e
                    continue
            
            # If all attempts failed
            raise Exception(f"Cannot connect to ERPNext after trying multiple URLs. Last error: {str(last_exception)}")
            
        except Exception as e:
            logger.error(f"ERPNext API Error: {str(e)}")
            raise

    def onboard_company(self, payload: dict):
        return self.post(
            "mymobi_whatsapp_saas.mymobi_whatsapp_saas.api.saas_onboarding.saas_onboard",
            payload
        )
    
    def create_customer(self, payload: dict):
        return self.post(
            "mymobi_whatsapp_saas.mymobi_whatsapp_saas.api.customer.create_or_get_customer",
            payload
        )
    
    def log_message(self, payload: dict):
        return self.post(
            "mymobi_whatsapp_saas.mymobi_whatsapp_saas.api.conversation.log_message",
            payload
        )

    def update_usage(self, payload: dict):
        return self.post(
            "mymobi_whatsapp_saas.mymobi_whatsapp_saas.api.billing.update_usage",
            payload
        )
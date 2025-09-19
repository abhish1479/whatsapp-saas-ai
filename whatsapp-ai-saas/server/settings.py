
import os

class Settings:
    APP_ENV = os.getenv("APP_ENV","dev")
    API_HOST = os.getenv("API_HOST","0.0.0.0")
    API_PORT = int(os.getenv("API_PORT","8000"))
    JWT_SECRET = os.getenv("JWT_SECRET","dev_secret")
    JWT_EXPIRE_MIN = int(os.getenv("JWT_EXPIRE_MIN","43200"))
    DB_HOST=os.getenv("DB_HOST","db")
    DB_PORT=int(os.getenv("DB_PORT","5432"))
    DB_NAME=os.getenv("DB_NAME","wa_saas")
    DB_USER=os.getenv("DB_USER","wa_user")
    DB_PASS=os.getenv("DB_PASS","wa_pass")
    REDIS_URL=os.getenv("REDIS_URL","redis://redis:6379/0")

    WA_PROVIDER=os.getenv("WA_PROVIDER","dialog360")
    DIALOG360_BASE_URL=os.getenv("DIALOG360_BASE_URL","https://waba.360dialog.io")
    DIALOG360_API_KEY=os.getenv("DIALOG360_API_KEY","")

    WA_CLOUD_BASE_URL=os.getenv("WA_CLOUD_BASE_URL","https://graph.facebook.com/v20.0")
    WA_CLOUD_TOKEN=os.getenv("WA_CLOUD_TOKEN","")
    WA_CLOUD_PHONE_ID=os.getenv("WA_CLOUD_PHONE_ID","")
    WA_CLOUD_BUSINESS_ID=os.getenv("WA_CLOUD_BUSINESS_ID","")
    WA_VERIFY_TOKEN=os.getenv("WA_VERIFY_TOKEN","verify-me")

    MODERATION_ENABLED=os.getenv("MODERATION_ENABLED","true").lower()=="true"
    OPENAI_API_KEY=os.getenv("OPENAI_API_KEY","")

    CREDIT_COST_TEXT=int(os.getenv("CREDIT_COST_TEXT","1"))
    CREDIT_COST_MEDIA=int(os.getenv("CREDIT_COST_MEDIA","2"))
    DEDUCT_ON_RECEIVE=os.getenv("DEDUCT_ON_RECEIVE","true").lower()=="true"
    FREE_TRIAL_CREDITS=int(os.getenv("FREE_TRIAL_CREDITS","500"))

    RAZORPAY_KEY_ID = os.getenv("RAZORPAY_KEY_ID","")
    RAZORPAY_KEY_SECRET = os.getenv("RAZORPAY_KEY_SECRET","")
    RAZORPAY_WEBHOOK_SECRET = os.getenv("RAZORPAY_WEBHOOK_SECRET","")
    CURRENCY = os.getenv("CURRENCY","INR")

    PACKS = [
        {
            "id": os.getenv("PACK_STARTER_ID","starter_1000"),
            "amount": int(os.getenv("PACK_STARTER_AMOUNT","1000")),
            "credits": int(os.getenv("PACK_STARTER_CREDITS","1000")),
            "label": "Starter"
        },
        {
            "id": os.getenv("PACK_GROWTH_ID","growth_6000"),
            "amount": int(os.getenv("PACK_GROWTH_AMOUNT","5000")),
            "credits": int(os.getenv("PACK_GROWTH_CREDITS","6000")),
            "label": "Growth"
        },
        {
            "id": os.getenv("PACK_ENTERPRISE_ID","enterprise_70000"),
            "amount": int(os.getenv("PACK_ENTERPRISE_AMOUNT","50000")),
            "credits": int(os.getenv("PACK_ENTERPRISE_CREDITS","70000")),
            "label": "Enterprise"
        },
    ]

settings = Settings()

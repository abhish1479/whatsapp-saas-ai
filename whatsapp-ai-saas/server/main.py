
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import auth, kyc, provisioning, leads, conversation, rag, social_auth, wallet, webhooks, templates, analytics, billing
from middleware.logging import RequestLoggingMiddleware
from prometheus_fastapi_instrumentator import Instrumentator
from services.metrics import inc_credits
from services.metrics import inc_message
from routers import onboarding
from database import Base, engine




app = FastAPI(title="WhatsApp AI Agent SaaS", version="1.0")
Instrumentator().instrument(app).expose(app)


app.add_middleware(RequestLoggingMiddleware)


app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

Base.metadata.create_all(bind=engine)

app.include_router(onboarding.router)
app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(social_auth.router, tags=["social_auth"])
app.include_router(provisioning.router, prefix="/provision", tags=["provision"])
app.include_router(templates.router, prefix="/templates", tags=["templates"])
app.include_router(leads.router, prefix="/leads", tags=["leads"])
app.include_router(conversation.router, prefix="/conversation", tags=["conversation"])
app.include_router(rag.router, prefix="/rag", tags=["rag"])
app.include_router(wallet.router, prefix="/wallet", tags=["wallet"])
app.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
app.include_router(billing.router, prefix="/billing", tags=["billing"])
app.include_router(webhooks.router, prefix="/webhooks", tags=["webhooks"])
app.include_router(kyc.router)

@app.get("/healthz")
def healthz():
    return {"ok": True}


from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routers import auth, provisioning, leads, conversation, rag, wallet, webhooks, templates, analytics, billing

app = FastAPI(title="WhatsApp AI Agent SaaS", version="1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/auth", tags=["auth"])
app.include_router(provisioning.router, prefix="/provision", tags=["provision"])
app.include_router(templates.router, prefix="/templates", tags=["templates"])
app.include_router(leads.router, prefix="/leads", tags=["leads"])
app.include_router(conversation.router, prefix="/conversation", tags=["conversation"])
app.include_router(rag.router, prefix="/rag", tags=["rag"])
app.include_router(wallet.router, prefix="/wallet", tags=["wallet"])
app.include_router(analytics.router, prefix="/analytics", tags=["analytics"])
app.include_router(billing.router, prefix="/billing", tags=["billing"])
app.include_router(webhooks.router, prefix="/webhooks", tags=["webhooks"])

@app.get("/healthz")
def healthz():
    return {"ok": True}

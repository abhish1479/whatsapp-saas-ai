
# WhatsApp AI Agent SaaS — Full Source (Server + Onboarding Web)

**Stack**
- Backend: FastAPI, SQLAlchemy (Postgres), Redis, Chroma (RAG), Razorpay billing, WhatsApp providers (360dialog + Cloud API)
- Frontend: Vite + React onboarding site (signup/login, check credits, buy packs, add lead)

**Run locally**
```bash
cp .env.example .env
docker compose up --build

# Stop all containers (data remains in volumes)
docker-compose down
# Start only the server and worker
docker-compose start wa_server wa_worker

# Stop all containers (data remains in volumes)
docker-compose down
# Start all containers (data persists)
docker-compose up -d
```
- API docs: http://localhost:8000/docs
- Web: http://localhost:5173

**Configure**
- Edit `.env` to add Razorpay and WhatsApp provider keys (360dialog or Cloud API).
- For webhooks in local dev, expose via ngrok:
  - `ngrok http 8000`
  - Set Razorpay webhook to `https://<ngrok-domain>/billing/webhook`
  - Set WhatsApp webhook to `https://<ngrok-domain>/webhooks/wa`



#API Docs → http://localhost:8000/docs

#Flutter Onboarding UI → http://localhost:8000/app

#Grafana → http://localhost:3000
 #(user: admin, pass: admin)

#Prometheus → http://localhost:9090
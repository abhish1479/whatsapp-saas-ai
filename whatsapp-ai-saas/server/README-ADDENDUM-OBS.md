# Patch: Observability, Conversations, Summarization, Moderation Logs

## New Features
1. **Structured logging middleware** (`server/middleware/logging.py`)
2. **Conversations + Messages + Moderation logs tables** (`002_create_conversations.sql`)
3. **Conversation API** (`routers/conversation.py`)
4. **Summarization Worker** (`workers/summary_worker.py`)
5. **Moderation Logs API** (`routers/analytics.py` extension)

## Setup
1. Apply migration:
   ```bash
   psql "$DATABASE_URL" -f server/migrations/002_create_conversations.sql
   ```
2. Add middleware in `main.py`:
   ```python
   from server.middleware.logging import RequestLoggingMiddleware
   app.add_middleware(RequestLoggingMiddleware)
   ```
3. Run summarizer worker (point to your LLM endpoint):
   ```bash
   python -m server.workers.summary_worker
   ```
4. Prometheus/OpenTelemetry:
   - Add `prometheus-fastapi-instrumentator` in requirements
   - In `main.py`:
     ```python
     from prometheus_fastapi_instrumentator import Instrumentator
     Instrumentator().instrument(app).expose(app)
     ```

## Endpoints
- `GET /conversations/{id}` → messages log
- `GET /conversations/{id}/summary` → LLM-generated summary
- `GET /analytics/moderation-logs` → flagged content

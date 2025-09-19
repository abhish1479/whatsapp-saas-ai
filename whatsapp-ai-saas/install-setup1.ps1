<#
.SYNOPSIS
    Environment setup for WhatsApp AI SaaS
.DESCRIPTION
    Installs required software, sets environment variables, runs DB migrations,
    and starts the stack. Keep updating this script as new patches are added.
#>

Write-Host "=== WhatsApp AI SaaS Setup Script ==="

# 1. Check Python
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "Python not found. Please install Python 3.11+ manually and re-run."
    exit 1
}
python --version

# 2. Install pip dependencies
Write-Host "Installing server dependencies..."
pip install -r whatsapp-ai-saas/server/requirements.txt

# 3. Install extra tools
Write-Host "Installing PostgreSQL client and Redis (optional)..."
# Windows: suggest Chocolatey
if (-not (Get-Command psql -ErrorAction SilentlyContinue)) {
    choco install postgresql -y
}
if (-not (Get-Command redis-server -ErrorAction SilentlyContinue)) {
    choco install redis-64 -y
}

# 4. Ensure Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Docker not found. Please install Docker Desktop and re-run."
    exit 1
}
docker --version

# 5. Create .env file if missing
$envPath = "whatsapp-ai-saas/.env"
if (-not (Test-Path $envPath)) {
@"
DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/whatsapp
REDIS_URL=redis://localhost:6379/0
WEBHOOK_QUEUE=wh_inbound_queue
WHATSAPP_VERIFY_TOKEN=change-me
LLM_SUMMARY_URL=http://localhost:8001/summarize
"@ | Out-File $envPath -Encoding utf8
Write-Host ".env created at $envPath"
} else {
    Write-Host ".env already exists, skipping."
}

# 6. Run DB migrations
Write-Host "Running database migrations..."
$env:PGPASSWORD="pass"
psql -h localhost -U user -d whatsapp -f whatsapp-ai-saas/server/migrations/001_create_credit_ledger.sql
psql -h localhost -U user -d whatsapp -f whatsapp-ai-saas/server/migrations/002_create_conversations.sql
psql -h localhost -U user -d whatsapp -f whatsapp-ai-saas/server/migrations/003_onboarding.sql

# 7. Build and start stack
Write-Host "Starting docker compose..."
docker compose -f whatsapp-ai-saas/docker-compose.yml -f whatsapp-ai-saas/compose.override.yml up --build -d

Write-Host "=== Setup Complete ==="
Write-Host "Server running on http://localhost:8000"
Write-Host "Prometheus metrics available at /metrics"

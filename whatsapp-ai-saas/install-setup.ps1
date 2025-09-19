# ===========================
# WhatsApp SaaS AI Setup Script
# ===========================

Write-Host "🚀 Starting WhatsApp SaaS AI Setup..."

# 1. Check Docker
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# 2. Load env file
$envFile = ".env"
if (-not (Test-Path $envFile)) {
    Write-Host "❌ .env file missing. Please copy from .env.example and fill credentials." -ForegroundColor Red
    exit 1
}
Write-Host "✅ .env file loaded"

# 3. Start Docker stack
Write-Host "🐳 Starting Docker containers..."
docker compose -f docker-compose.yml -f compose.override.yml -f compose.monitoring.yml up --build -d

# 4. Run migrations
Write-Host "📦 Running DB migrations..."
# Run migrations
docker compose exec db psql -U wa_user -d wa_saas -f server/migrations/001_init.sql
docker compose exec db psql -U wa_user -d wa_saas -f server/migrations/002_create_conversations.sql
docker compose exec db psql -U wa_user -d wa_saas -f server/migrations/003_onboarding.sql

# 5. Flutter build (web)
if (Test-Path "flutter_onboarding") {
    Write-Host "📱 Building Flutter web onboarding..."
    cd flutter_onboarding
    flutter pub get
    flutter build web
    cd ..
    Write-Host "✅ Flutter onboarding built at flutter_onboarding/build/web/"
} else {
    Write-Host "⚠️ flutter_onboarding directory not found, skipping build"
}

# 6. Open URLs
Write-Host "🌐 Opening URLs in browser..."
Start-Process "http://localhost:8000/docs"
Start-Process "http://localhost:8000/app"
Start-Process "http://localhost:3000"

Write-Host "✅ Setup completed! API, Onboarding, and Grafana are live."

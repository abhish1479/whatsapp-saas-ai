<# 
.SYNOPSIS
  Bootstrap WhatsApp AI SaaS dev env (Windows).

.DESCRIPTION
  - Verifies Python, Docker, psql
  - Creates .env (if missing)
  - Applies DB migrations (001, 002, 003)
  - Starts docker compose (server + redis + worker; optional monitoring)

.PARAMETER RepoRoot
  Path to the whatsapp-ai-saas repo folder (this script's folder by default)

.PARAMETER PgHost, PgUser, PgPassword, PgDb, PgPort
  Connection params for psql (used for migrations)

.PARAMETER WithMonitoring
  Include Prometheus + Grafana compose file

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File ".\install-setup.ps1" -WithMonitoring
#>

[CmdletBinding()]
param(
  [string]$RepoRoot = $PSScriptRoot,
  [string]$PgHost = "localhost",
  [string]$PgUser = "wa_saas_user",
  [string]$PgPassword = "smileplz",
  [string]$PgDb = "whatsappdb",
  [int]$PgPort = 5433,
  [switch]$WithMonitoring
)

function Write-Section($msg) {
  Write-Host "`n=== $msg ===" -ForegroundColor Cyan
}

function Ensure-Command($name, $help) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "$name not found. $help"
  }
}

# --- 0) Move to repo root (so relative compose paths work) ---
Set-Location -Path $RepoRoot

Write-Section "Environment summary"
Write-Host "RepoRoot       : ${RepoRoot}"
Write-Host "DB (psql)      : ${PgUser}@${PgHost}:${PgPort} / ${PgDb}"
Write-Host "Monitoring     : $($WithMonitoring.IsPresent)"

# --- 1) Check essentials ---
Write-Section "Checking prerequisites"

try {
  Ensure-Command python "Install Python 3.11+ from https://www.python.org/downloads/"
  $pyv = (python --version)
  Write-Host "Python: $pyv"
} catch { throw }

try {
  Ensure-Command docker "Install Docker Desktop: https://www.docker.com/products/docker-desktop/"
  docker --version | Out-Null
  Write-Host "Docker: OK"
} catch { throw }

# psql (from PostgreSQL or PgAdmin)
try {
  Ensure-Command psql "Install PostgreSQL (client) or add psql to PATH. Easiest via https://www.postgresql.org/download/"
  $psqlOk = $true
  Write-Host "psql: OK"
} catch { 
  $psqlOk = $false
  Write-Warning "psql not found. Migrations will fail without psql. Install PostgreSQL client first."
}

# --- 2) Python server deps ---
Write-Section "Installing server Python dependencies (pip)"
$req = Join-Path $RepoRoot "server\requirements.txt"
if (Test-Path $req) {
  python -m pip install --upgrade pip
  python -m pip install -r $req
} else {
  Write-Warning "requirements.txt not found at $req (skipping pip install)"
}

# --- 3) Create .env if missing ---
Write-Section "Ensuring .env"

$envPath = Join-Path $RepoRoot ".env"
if (-not (Test-Path $envPath)) {
@"
# Server runtime
DATABASE_URL=postgresql+asyncpg://${PgUser}:${PgPassword}@${PgHost}:${PgPort}/${PgDb}
REDIS_URL=redis://localhost:6379/0
WEBHOOK_QUEUE=wh_inbound_queue
WHATSAPP_VERIFY_TOKEN=change-me
LLM_SUMMARY_URL=http://localhost:8001/summarize

# WhatsApp Cloud API
WHATSAPP_API_URL=https://graph.facebook.com/v19.0
WHATSAPP_PHONE_NUMBER_ID=
WHATSAPP_ACCESS_TOKEN=
"@ | Out-File -Encoding UTF8 $envPath
  Write-Host "Created .env"
} else {
  Write-Host ".env already exists (skipping)"
}

# --- 4) Apply migrations ---
Write-Section "Applying database migrations"

if (-not $psqlOk) {
  Write-Warning "Skipping migrations because psql not found."
} else {
  $mig1 = Join-Path $RepoRoot "server\migrations\001_create_credit_ledger.sql"
  $mig2 = Join-Path $RepoRoot "server\migrations\002_create_conversations.sql"
  $mig3 = Join-Path $RepoRoot "server\migrations\003_onboarding.sql"

  $env:PGPASSWORD = $PgPassword
  & psql -h $PgHost -p $PgPort -U $PgUser -d $PgDb -c "CREATE EXTENSION IF NOT EXISTS pgcrypto;" | Out-Null

  foreach ($mig in @($mig1, $mig2, $mig3)) {
    if ($null -eq $mig) {
      Write-Warning "Migration variable is null"
      continue
    }
    if (Test-Path $mig) {
      Write-Host "Running $(Split-Path $mig -Leaf)"
      & psql -h $PgHost -p $PgPort -U $PgUser -d $PgDb -f $mig
    } else {
      Write-Warning "Migration file missing: $mig"
    }
  }
}

# --- 5) Start Docker stack ---
Write-Section "Starting Docker Compose stack"

$baseCompose = Join-Path $RepoRoot "docker-compose.yml"
$overrideCompose = Join-Path $RepoRoot "compose.override.yml"
$monitorCompose = Join-Path $RepoRoot "compose.monitoring.yml"

if (-not (Test-Path $baseCompose)) {
  throw "docker-compose.yml not found at $baseCompose"
}

# Build list of -f files
$composeFiles = @("-f", $baseCompose)

if (Test-Path $overrideCompose) {
  $composeFiles += @("-f", $overrideCompose)
} else {
  Write-Warning "compose.override.yml not found (Redis + worker may not start)."
}

if ($WithMonitoring.IsPresent) {
  if (Test-Path $monitorCompose) {
    $composeFiles += @("-f", $monitorCompose)
  } else {
    Write-Warning "compose.monitoring.yml not found (prom/grafana won’t start)."
  }
}

# Run `docker compose up`
docker compose $composeFiles up --build -d

Write-Section "Done"
Write-Host "Server:           http://localhost:8000"
Write-Host "Prometheus:       http://localhost:9090   (if monitoring enabled)"
Write-Host "Grafana:          http://localhost:3000   (if monitoring enabled; admin/admin)"

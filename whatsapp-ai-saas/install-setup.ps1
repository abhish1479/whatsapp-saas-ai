# ============================================
# WhatsApp SaaS Project Setup for Windows 10/11
# Run this script in PowerShell as Administrator
# ============================================

Write-Host "🚀 Starting setup..."

# --- Step 1: Install Chocolatey (if missing) ---
if (!(Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Host "🍫 Installing Chocolatey..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
} else {
    Write-Host "✔ Chocolatey already installed."
}

# Refresh environment
refreshenv | Out-Null

# --- Step 2: Install Docker Desktop ---
if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "🐳 Installing Docker Desktop..."
    choco install docker-desktop -y
} else {
    Write-Host "✔ Docker Desktop already installed."
}

# --- Step 3: Install Node.js (for frontend) ---
if (!(Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "⬢ Installing Node.js..."
    choco install nodejs-lts -y
} else {
    Write-Host "✔ Node.js already installed."
}

# --- Step 4: Install ngrok (for webhook tunneling) ---
if (!(Get-Command ngrok -ErrorAction SilentlyContinue)) {
    Write-Host "🌐 Installing ngrok..."
    choco install ngrok -y
} else {
    Write-Host "✔ ngrok already installed."
}

# --- Step 5: Install PostgreSQL client tools (optional) ---
if (!(Get-Command psql -ErrorAction SilentlyContinue)) {
    Write-Host "🐘 Installing PostgreSQL client..."
    choco install postgresql -y
} else {
    Write-Host "✔ PostgreSQL client already installed."
}

# --- Step 6: Install VS Code ---
if (!(Get-Command code -ErrorAction SilentlyContinue)) {
    Write-Host "📝 Installing Visual Studio Code..."
    choco install vscode -y
} else {
    Write-Host "✔ VS Code already installed."
}

# --- Step 7: Verify Python ---
if (!(Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Host "⚠ Python not found. Please install Python 3.11+ manually."
} else {
    $pyver = python --version
    Write-Host "✔ Found $pyver"
}

Write-Host "🎉 Setup complete!"
Write-Host "👉 Please restart your machine if Docker Desktop was installed."

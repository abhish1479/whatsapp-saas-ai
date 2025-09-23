# cleanup.ps1
# Removes large file from Git history and pushes cleaned repo to GitHub

# 1. Install git-filter-repo if not already installed
# pip install git-filter-repo

Write-Host ">>> Removing whatsapp-ai-saas/flutter_onboarding (2).zip from history..."

# Run filter-repo
python -m git_filter_repo --path "whatsapp-ai-saas/flutter_onboarding (2).zip" --invert-paths

Write-Host ">>> File removed from history."

# 2. Add *.zip to .gitignore so it won't happen again
Add-Content .gitignore "*.zip"

git add .gitignore
git commit -m "Add zip files to .gitignore"

# 3. Force push cleaned repo
git push origin main --force

Write-Host ">>> Cleanup done. Large file removed from Git history."

# Virtual Environment Setup Script for Documake
# This script creates a virtual environment, installs dependencies, and activates it

Write-Host "Setting up virtual environment for Documake..." -ForegroundColor Cyan

# Check if virtual environment already exists
if (Test-Path "venv") {
    Write-Host "Virtual environment already exists. Removing old one..." -ForegroundColor Yellow
    Remove-Item -Recurse -Force venv
}

# Create virtual environment
Write-Host "Creating virtual environment..." -ForegroundColor Green
python -m venv venv

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to create virtual environment. Make sure Python is installed." -ForegroundColor Red
    exit 1
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Green
& .\venv\Scripts\Activate.ps1

# Upgrade pip
Write-Host "Upgrading pip..." -ForegroundColor Green
python -m pip install --upgrade pip

# Install requirements
Write-Host "Installing requirements from requirements.txt..." -ForegroundColor Green
pip install -r requirements.txt

if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to install requirements." -ForegroundColor Red
    exit 1
}

Write-Host "`nSetup complete! Virtual environment is now active." -ForegroundColor Green
Write-Host "To activate the virtual environment in the future, run:" -ForegroundColor Cyan
Write-Host "  .\venv\Scripts\Activate.ps1" -ForegroundColor White
Write-Host "`nTo deactivate, simply run: deactivate" -ForegroundColor Cyan


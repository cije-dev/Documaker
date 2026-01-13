# Production Launch Script for Documake
# This script launches the application using Waitress WSGI server

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Starting Documake Production Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if virtual environment exists
if (-not (Test-Path "venv")) {
    Write-Host "Error: Virtual environment not found!" -ForegroundColor Red
    Write-Host "Please run setup_deployment.ps1 first to configure the deployment." -ForegroundColor Yellow
    exit 1
}

# Activate virtual environment
Write-Host "Activating virtual environment..." -ForegroundColor Green
& .\venv\Scripts\Activate.ps1

# Check if Waitress is installed
Write-Host "Checking Waitress installation..." -ForegroundColor Green
pip show waitress 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Waitress not found. Installing..." -ForegroundColor Yellow
    pip install waitress
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to install Waitress." -ForegroundColor Red
        exit 1
    }
}

# Load configuration from .env if it exists
$docuHost = "0.0.0.0"
$port = 8080
$threads = 4

if (Test-Path ".env") {
    Write-Host "Loading configuration from .env..." -ForegroundColor Green
    Get-Content ".env" | ForEach-Object {
        if ($_ -match '^HOST=(.+)$') {
            $script:docuHost = $matches[1]
        }
        if ($_ -match '^PORT=(\d+)$') {
            $script:port = [int]$matches[1]
        }
        if ($_ -match '^THREADS=(\d+)$') {
            $script:threads = [int]$matches[1]
        }
    }
}

# Display configuration
Write-Host ""
Write-Host "Server Configuration:" -ForegroundColor Cyan
Write-Host "  Host: $docuHost" -ForegroundColor White
Write-Host "  Port: $port" -ForegroundColor White
Write-Host "  Threads: $threads" -ForegroundColor White
Write-Host ""
Write-Host "Starting Waitress server..." -ForegroundColor Green
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""
Write-Host "Access the application at:" -ForegroundColor Cyan
Write-Host "  http://localhost:$port" -ForegroundColor White
Write-Host "  http://$($env:COMPUTERNAME):$port" -ForegroundColor White
Write-Host ""

# Set environment variables for Python script
$env:HOST = $docuHost
$env:PORT = $port
$env:THREADS = $threads

# Run the Python production script
python run_production.py


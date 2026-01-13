# Deployment Packaging Script for Documake
# This script creates a zip file with all necessary files for deployment

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Documake Deployment Packaging" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get current directory and project name
$projectRoot = Get-Location
$projectName = Split-Path -Leaf $projectRoot
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipFileName = "Documake_Deployment_$timestamp.zip"
$zipPath = Join-Path $projectRoot $zipFileName

Write-Host "Creating deployment package..." -ForegroundColor Green
Write-Host "Package name: $zipFileName" -ForegroundColor Cyan
Write-Host ""

# Files and directories to include
$filesToInclude = @(
    "app.py",
    "requirements.txt",
    "templates",
    "static",
    "setup_deployment.ps1",
    "setup_deployment.bat",
    "run_production.ps1",
    "run_production.bat",
    "run_production.py",
    "setup_venv.ps1",
    "setup_venv.bat"
)

# Files and patterns to exclude
$excludePatterns = @(
    "__pycache__",
    "*.pyc",
    "*.pyo",
    "*.pyd",
    ".env",
    "*.db",
    "*.log",
    "venv",
    ".git",
    ".gitignore",
    "*.zip",
    "logs",
    ".DS_Store",
    "Thumbs.db"
)

# Check if required files exist
$missingFiles = @()
foreach ($file in $filesToInclude) {
    if (-not (Test-Path $file)) {
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "Warning: The following files/directories are missing:" -ForegroundColor Yellow
    foreach ($file in $missingFiles) {
        Write-Host "  - $file" -ForegroundColor Yellow
    }
    $response = Read-Host "Continue anyway? (y/N)"
    if ($response -ne 'y' -and $response -ne 'Y') {
        Write-Host "Packaging cancelled." -ForegroundColor Red
        exit 1
    }
}

# Remove existing zip if it exists
if (Test-Path $zipPath) {
    Write-Host "Removing existing package..." -ForegroundColor Yellow
    Remove-Item $zipPath -Force
}

# Create temporary directory for packaging
$tempDir = Join-Path $env:TEMP "Documake_Package_$timestamp"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir | Out-Null

Write-Host "Copying files to temporary directory..." -ForegroundColor Green

# Copy files and directories
foreach ($item in $filesToInclude) {
    if (Test-Path $item) {
        $sourcePath = Join-Path $projectRoot $item
        $destPath = Join-Path $tempDir $item
        
        if (Test-Path $sourcePath -PathType Container) {
            # It's a directory
            Write-Host "  Copying directory: $item" -ForegroundColor Gray
            Copy-Item -Path $sourcePath -Destination $destPath -Recurse -Force
        } else {
            # It's a file
            Write-Host "  Copying file: $item" -ForegroundColor Gray
            $destDir = Split-Path -Parent $destPath
            if (-not (Test-Path $destDir)) {
                New-Item -ItemType Directory -Path $destDir -Force | Out-Null
            }
            Copy-Item -Path $sourcePath -Destination $destPath -Force
        }
    }
}

# Clean up excluded patterns
Write-Host "Cleaning up excluded files..." -ForegroundColor Green
foreach ($pattern in $excludePatterns) {
    $items = Get-ChildItem -Path $tempDir -Recurse -Force | Where-Object {
        $_.Name -like $pattern -or 
        $_.FullName -like "*\$pattern\*" -or
        $_.FullName -like "*\$pattern"
    }
    
    foreach ($item in $items) {
        Write-Host "  Removing: $($item.FullName.Replace($tempDir, ''))" -ForegroundColor Gray
        Remove-Item -Path $item.FullName -Recurse -Force -ErrorAction SilentlyContinue
    }
}

# Remove __pycache__ directories specifically
$pycacheDirs = Get-ChildItem -Path $tempDir -Recurse -Directory -Filter "__pycache__" -Force
foreach ($dir in $pycacheDirs) {
    Write-Host "  Removing: $($dir.FullName.Replace($tempDir, ''))" -ForegroundColor Gray
    Remove-Item -Path $dir.FullName -Recurse -Force
}

# Create README for deployment
$readmeContent = @"
# Documake Deployment Package

This package contains all necessary files to deploy Documake.

## Contents

- app.py - Main application file
- requirements.txt - Python dependencies
- templates/ - HTML templates (including landing page)
- static/ - CSS and JavaScript files
- Deployment scripts (setup_deployment.*, run_production.*)
- Virtual environment setup scripts (setup_venv.*)

## About Documake

Documake is a professional document generation platform designed and developed by CIJE using Cursor AI. It provides comprehensive tools for creating paystubs, managing employee records, and generating transaction histories.

## Deployment Instructions

### 1. Extract this zip file to your deployment location

### 2. Run the deployment configuration script:

**Windows PowerShell:**
```powershell
.\setup_deployment.ps1
```

**Windows Command Prompt:**
```cmd
setup_deployment.bat
```

This will:
- Create a virtual environment
- Install all dependencies
- Set up production configuration

### 3. Configure your environment:

Edit the `.env` file (created by setup script) and update:
- SECRET_KEY (IMPORTANT: Change to a random secret key)
- HOST (default: 0.0.0.0)
- PORT (default: 8080)
- THREADS (default: 4)

### 4. Launch the production server:

**Windows PowerShell:**
```powershell
.\run_production.ps1
```

**Windows Command Prompt:**
```cmd
run_production.bat
```

**Or using Python directly:**
```bash
python run_production.py
```

### 5. Access the application:

Open your browser and navigate to:
- http://localhost:8080 (or your configured port)

## Important Notes

- The database (paystub.db) will be created automatically on first run
- Make sure to change the SECRET_KEY in .env for security
- The application will be accessible from other machines on your network
- Use a reverse proxy (like nginx) for production deployments with SSL

## System Requirements

- Python 3.8 or higher
- Windows, Linux, or macOS
- Internet connection (for initial package installation)

## Support

For issues or questions, refer to the main project documentation.
"@

$readmePath = Join-Path $tempDir "DEPLOYMENT_README.txt"
$readmeContent | Out-File -FilePath $readmePath -Encoding UTF8
Write-Host "  Created: DEPLOYMENT_README.txt" -ForegroundColor Gray

# Create the zip file
Write-Host ""
Write-Host "Creating zip archive..." -ForegroundColor Green
try {
    # Use .NET compression for better compatibility
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath)
    
    # Get file size
    $fileSize = (Get-Item $zipPath).Length / 1MB
    $fileSizeFormatted = "{0:N2}" -f $fileSize
    
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "Package Created Successfully!" -ForegroundColor Green
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Package: $zipFileName" -ForegroundColor Cyan
    Write-Host "Location: $zipPath" -ForegroundColor Cyan
    Write-Host "Size: $fileSizeFormatted MB" -ForegroundColor Cyan
    Write-Host ""
    
} catch {
    Write-Host "Error creating zip file: $_" -ForegroundColor Red
    Write-Host "Falling back to Compress-Archive..." -ForegroundColor Yellow
    
    try {
        Compress-Archive -Path "$tempDir\*" -DestinationPath $zipPath -Force
        Write-Host "Package created using Compress-Archive" -ForegroundColor Green
    } catch {
        Write-Host "Error: Failed to create zip file: $_" -ForegroundColor Red
        exit 1
    }
}

# Clean up temporary directory
Write-Host "Cleaning up temporary files..." -ForegroundColor Gray
Remove-Item -Path $tempDir -Recurse -Force

Write-Host ""
Write-Host "Deployment package is ready!" -ForegroundColor Green
Write-Host "You can now distribute this zip file for deployment." -ForegroundColor Cyan
Write-Host ""


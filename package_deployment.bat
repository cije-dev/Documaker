@echo off
REM Deployment Packaging Script for Documake
REM This script creates a zip file with all necessary files for deployment

echo ========================================
echo Documake Deployment Packaging
echo ========================================
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if errorlevel 1 (
    echo Error: PowerShell is required for packaging.
    echo Please use package_deployment.ps1 instead, or install PowerShell.
    pause
    exit /b 1
)

REM Run the PowerShell version
echo Running PowerShell packaging script...
echo.
powershell -ExecutionPolicy Bypass -File "%~dp0package_deployment.ps1"

if errorlevel 1 (
    echo.
    echo Packaging failed!
    pause
    exit /b 1
)

echo.
pause


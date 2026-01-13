@echo off
REM Deployment Configuration Script for Documake
REM This script configures the application for production deployment using Waitress

echo ========================================
echo Documake Deployment Configuration
echo ========================================
echo.

REM Check Python installation
echo Checking Python installation...
python --version >nul 2>&1
if errorlevel 1 (
    echo Error: Python is not installed or not in PATH
    echo Please install Python 3.8 or higher from python.org
    pause
    exit /b 1
)
python --version

REM Check if virtual environment exists
if exist venv (
    echo Virtual environment already exists.
    set /p RECREATE="Do you want to recreate it? (y/N): "
    if /i "%RECREATE%"=="y" (
        echo Removing old virtual environment...
        rmdir /s /q venv
    ) else (
        echo Using existing virtual environment.
        goto :activate
    )
)

REM Create virtual environment
echo Creating virtual environment...
python -m venv venv
if errorlevel 1 (
    echo Error: Failed to create virtual environment.
    pause
    exit /b 1
)

:activate
REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip --quiet

REM Install requirements
echo Installing production dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo Error: Failed to install requirements.
    pause
    exit /b 1
)

REM Create logs directory
if not exist logs (
    mkdir logs
    echo Created logs directory
)

REM Check database
echo Checking database...
if not exist paystub.db (
    echo Database will be created on first run.
) else (
    echo Database file exists.
)

echo.
echo ========================================
echo Deployment Configuration Complete!
echo ========================================
echo.
echo Next steps:
echo 1. Review production settings
echo 2. Run the production server with: run_production.bat
echo.
echo To activate the virtual environment manually:
echo   venv\Scripts\activate.bat
echo.

pause


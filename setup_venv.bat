@echo off
REM Virtual Environment Setup Script for Documake
REM This script creates a virtual environment, installs dependencies, and activates it

echo Setting up virtual environment for Documake...

REM Check if virtual environment already exists
if exist venv (
    echo Virtual environment already exists. Removing old one...
    rmdir /s /q venv
)

REM Create virtual environment
echo Creating virtual environment...
python -m venv venv

if errorlevel 1 (
    echo Error: Failed to create virtual environment. Make sure Python is installed.
    pause
    exit /b 1
)

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Upgrade pip
echo Upgrading pip...
python -m pip install --upgrade pip

REM Install requirements
echo Installing requirements from requirements.txt...
pip install -r requirements.txt

if errorlevel 1 (
    echo Error: Failed to install requirements.
    pause
    exit /b 1
)

echo.
echo Setup complete! Virtual environment is now active.
echo To activate the virtual environment in the future, run:
echo   venv\Scripts\activate.bat
echo.
echo To deactivate, simply run: deactivate
echo.

pause


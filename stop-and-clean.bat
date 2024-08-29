@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo Running Nussknacker Quickstart clean up...
echo.

docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: No Docker found. Docker is required to run this Quickstart. See https://docs.docker.com/engine/install/
    exit /b 1
)

docker compose version >nul 2>&1
if errorlevel 1 (
    echo ERROR: No docker compose found. It seems you have to upgrade your Docker installation. See https://docs.docker.com/engine/install/
    exit /b 2
)

docker compose config >nul 2>&1
if errorlevel 1 (
    echo ERROR: Cannot validate docker compose configuration. It seems you have to upgrade your Docker installation. See https://docs.docker.com/engine/install/
    exit /b 3
)

docker compose down -v

echo All is cleaned. Goodbye


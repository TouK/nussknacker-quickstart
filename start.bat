@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo Running Nussknacker Quickstart...
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

docker compose up -d --build --remove-orphans --wait 

echo.
echo Nussknacker and its dependencies are up and running.
echo Open http://localhost:8080 and log in as admin:admin...

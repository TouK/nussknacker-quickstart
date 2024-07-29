@echo off
setlocal enabledelayedexpansion

cd /d "%~dp0"

echo.
echo  ███    ██ ██    ██ ███████ ███████ ██   ██ ███    ██  █████   ██████ ██   ██ ███████ ██████
echo  ████   ██ ██    ██ ██      ██      ██  ██  ████   ██ ██   ██ ██      ██  ██  ██      ██   ██
echo  ██ ██  ██ ██    ██ ███████ ███████ █████   ██ ██  ██ ███████ ██      █████   █████   ██████
echo  ██  ██ ██ ██    ██      ██      ██ ██  ██  ██  ██ ██ ██   ██ ██      ██  ██  ██      ██   ██
echo  ██   ████  ██████  ███████ ███████ ██   ██ ██   ████ ██   ██  ██████ ██   ██ ███████ ██   ██
echo.
echo                                                                                QUICKSTART
echo.

echo Running Nussknacker Quickstart ...
echo.

docker --version >nul 2>&1
if errorlevel 1 (
    echo No Docker found. Docker is required to run this Quickstart. See https://docs.docker.com/engine/install/
    exit /b 1
)

docker compose version >nul 2>&1
if errorlevel 1 (
    echo No docker compose found. It seems you have to upgrade your Docker installation. See https://docs.docker.com/engine/install/
    exit /b 2
)

docker compose config >nul 2>&1
if errorlevel 1 (
    echo Cannot validate docker compose configuration. It seems you have to upgrade your Docker installation. See https://docs.docker.com/engine/install/
    exit /b 3
)

docker compose up -d --build --wait

echo.
echo Nussknacker and its dependencies are up and running.
echo Open http://localhost:8080 and log in as admin:admin ...

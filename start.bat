@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

echo.
echo      _   ____  ____________ __ __ _   _____   ________ __ __________ 
echo     / | / / / / / ___/ ___// //_// | / /   | / ____/ //_// ____/ __ \
echo    /  |/ / / / /\__ \\__ \/ ,<  /  |/ / /| |/ /   / ,<  / __/ / /_/ /
echo   / /|  / /_/ /___/ /__/ / /| |/ /|  / ___ / /___/ /| |/ /___/ _, _/ 
echo  /_/ |_/\____//____/____/_/ |_/_/ |_/_/  |_\____/_/ |_/_____/_/ |_|  
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

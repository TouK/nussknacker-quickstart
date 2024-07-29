@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

set "BRANCH_NAME=%~1"
if "%BRANCH_NAME%"=="" set "BRANCH_NAME=main"

set "NU_QUICKSTART_DIR=nussknacker-quickstart-%BRANCH_NAME%"

powershell -Command "Invoke-WebRequest -Uri 'https://github.com/TouK/nussknacker-quickstart/archive/refs/heads/%BRANCH_NAME%.zip' -OutFile '%NU_QUICKSTART_DIR%.zip'"

if exist "%NU_QUICKSTART_DIR%" (
    rd /s /q "%NU_QUICKSTART_DIR%"
)

powershell -Command "Expand-Archive -Path '%NU_QUICKSTART_DIR%.zip' -DestinationPath ."

cd "%NU_QUICKSTART_DIR%"

call start.bat

endlocal

@echo off
setlocal
where pwsh >nul 2>nul
if %ERRORLEVEL% equ 0 (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "%~dp0agys.ps1" %*
) else (
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0agys.ps1" %*
)

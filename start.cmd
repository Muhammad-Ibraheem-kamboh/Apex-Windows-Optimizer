@echo off
title Apex Windows Optimizer
cd /d "%~dp0"

echo [1/2] Checking Apex Background Engine...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$c = Test-NetConnection -ComputerName 127.0.0.1 -Port 48888 -InformationLevel Quiet; if (-not $c) { Start-Process node -ArgumentList 'server.js' -WorkingDirectory '%~dp0' -WindowStyle Hidden; Start-Sleep -Seconds 1.5 }"

echo [2/2] Launching Native App Interface...
if exist "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" (
    start "" "%ProgramFiles(x86)%\Microsoft\Edge\Application\msedge.exe" --app="http://127.0.0.1:48888" --window-size=1200,800
) else if exist "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" (
    start "" "%ProgramFiles%\Microsoft\Edge\Application\msedge.exe" --app="http://127.0.0.1:48888" --window-size=1200,800
) else (
    start "" "http://127.0.0.1:48888"
)
exit

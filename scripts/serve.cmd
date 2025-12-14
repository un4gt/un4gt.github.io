@echo off
setlocal

rem Live-rebuild + serve docs. Override WATCH_STEP (ms) if needed.

if "%WATCH_STEP%"=="" set "WATCH_STEP=3000"

uv sync --frozen
if errorlevel 1 exit /b %errorlevel%

uv run --no-sync sphinx-autobuild docs docs\_build\html --watch-step %WATCH_STEP% %*

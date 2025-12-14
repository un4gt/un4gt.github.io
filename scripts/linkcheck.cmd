@echo off
setlocal

rem Check outbound links.

uv sync --frozen --no-dev
if errorlevel 1 exit /b %errorlevel%

uv run --no-sync --no-dev sphinx-build -b linkcheck docs docs\_build\linkcheck

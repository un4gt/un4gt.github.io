@echo off
setlocal

rem Build Sphinx HTML docs (installs deps into .venv via uv).

uv sync --frozen --no-dev
if errorlevel 1 exit /b %errorlevel%

uv run --no-sync --no-dev sphinx-build -M html docs docs\_build

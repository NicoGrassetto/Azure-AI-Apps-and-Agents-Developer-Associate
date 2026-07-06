#!/usr/bin/env pwsh
# Post-provision setup for Windows / PowerShell. Creates a virtual environment,
# installs dependencies, writes src/.env from azd outputs, and creates the agent
# with its grounding data. Invoked automatically by `azd up`.
$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root

$Venv = Join-Path $Root ".venv"
if ($IsWindows) {
    $Python = Join-Path $Venv "Scripts/python.exe"
} else {
    $Python = Join-Path $Venv "bin/python"
}

if (-not (Test-Path $Venv)) {
    Write-Host "Creating virtual environment (.venv)..."
    python -m venv $Venv
}

Write-Host "Installing Python dependencies..."
& $Python -m pip install --quiet --upgrade pip
& $Python -m pip install --quiet -r (Join-Path $Root "src/requirements.txt")

if ($env:PROJECT_ENDPOINT) {
    Write-Host "Writing src/.env from azd outputs..."
    $agent = if ($env:AGENT_NAME) { $env:AGENT_NAME } else { "it-support-agent" }
    $model = if ($env:MODEL_DEPLOYMENT_NAME) { $env:MODEL_DEPLOYMENT_NAME } else { "gpt-4o" }
    @(
        "PROJECT_ENDPOINT=$($env:PROJECT_ENDPOINT)",
        "AGENT_NAME=$agent",
        "MODEL_DEPLOYMENT_NAME=$model"
    ) | Set-Content -Path (Join-Path $Root "src/.env")
}

Write-Host "Creating the agent and uploading grounding data..."
Set-Location (Join-Path $Root "src")
& $Python setup_agent.py

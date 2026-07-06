#!/usr/bin/env pwsh
# Postprovision: write src/.env from azd deployment outputs.
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
if (-not $env:PROJECT_ENDPOINT) { Write-Host "PROJECT_ENDPOINT not set; skipping."; exit 0 }
Write-Host "Writing src/.env from azd outputs..."
@(
  "PROJECT_ENDPOINT=$($env:PROJECT_ENDPOINT)",
  "MODEL_DEPLOYMENT_NAME=$($env:MODEL_DEPLOYMENT_NAME)",
  "SERVER_URL=localhost",
  "ROUTING_AGENT_PORT=10009",
  "OUTLINE_AGENT_PORT=10008",
  "TITLE_AGENT_PORT=10007"
) | Set-Content -Path (Join-Path $Root "src/.env")
Write-Host "Done. See README.md to install dependencies and run the exercise."

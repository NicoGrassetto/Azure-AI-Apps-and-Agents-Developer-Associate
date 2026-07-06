#!/usr/bin/env pwsh
# Postprovision: write src/.env from azd deployment outputs.
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
if (-not $env:PROJECT_ENDPOINT) { Write-Host "PROJECT_ENDPOINT not set; skipping."; exit 0 }
Write-Host "Writing src/.env from azd outputs..."
@(
  "PROJECT_ENDPOINT=$($env:PROJECT_ENDPOINT)",
  "MODEL_DEPLOYMENT_NAME=$($env:MODEL_DEPLOYMENT_NAME)"
) | Set-Content -Path (Join-Path $Root "src/.env")
Write-Host "Done. See README.md to install dependencies and run the exercise."

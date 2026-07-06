#!/usr/bin/env pwsh
# Postprovision: write src/.env from azd deployment outputs.
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $PSScriptRoot
Set-Location $Root
if (-not $env:PROJECT_ENDPOINT) { Write-Host "PROJECT_ENDPOINT not set; skipping."; exit 0 }
Write-Host "Writing src/.env from azd outputs..."
$agentName = if ($env:AGENT_NAME) { $env:AGENT_NAME } else { "product-expert-agent" }
$container = if ($env:BLOB_CONTAINER_NAME) { $env:BLOB_CONTAINER_NAME } else { "product-data" }
@(
  "PROJECT_ENDPOINT=$($env:PROJECT_ENDPOINT)"
  "AGENT_NAME=$agentName"
  ""
  "# Reference values for the Foundry IQ knowledge-base setup (used in the portal):"
  "MODEL_DEPLOYMENT_NAME=$($env:MODEL_DEPLOYMENT_NAME)"
  "EMBEDDING_DEPLOYMENT_NAME=$($env:EMBEDDING_DEPLOYMENT_NAME)"
  "SEARCH_SERVICE_NAME=$($env:SEARCH_SERVICE_NAME)"
  "SEARCH_ENDPOINT=$($env:SEARCH_ENDPOINT)"
  "STORAGE_ACCOUNT_NAME=$($env:STORAGE_ACCOUNT_NAME)"
  "BLOB_CONTAINER_NAME=$container"
) | Set-Content -Path (Join-Path $Root "src/.env")
Write-Host "Done. See README.md to configure the knowledge base, complete the client, and run it."

#!/usr/bin/env sh
# Postprovision: write src/.env from azd deployment outputs (exposed as env vars).
set -eu
ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"
if [ -z "${PROJECT_ENDPOINT:-}" ]; then
  echo "PROJECT_ENDPOINT not set; skipping .env generation."
  exit 0
fi
echo "Writing src/.env from azd outputs..."
cat > src/.env <<EOF
PROJECT_ENDPOINT=${PROJECT_ENDPOINT}
AGENT_NAME=${AGENT_NAME:-product-expert-agent}

# Reference values for the Foundry IQ knowledge-base setup (used in the portal):
MODEL_DEPLOYMENT_NAME=${MODEL_DEPLOYMENT_NAME:-gpt-4o}
EMBEDDING_DEPLOYMENT_NAME=${EMBEDDING_DEPLOYMENT_NAME:-text-embedding-3-small}
SEARCH_SERVICE_NAME=${SEARCH_SERVICE_NAME:-}
SEARCH_ENDPOINT=${SEARCH_ENDPOINT:-}
STORAGE_ACCOUNT_NAME=${STORAGE_ACCOUNT_NAME:-}
BLOB_CONTAINER_NAME=${BLOB_CONTAINER_NAME:-product-data}
EOF
echo "Done. See README.md to configure the knowledge base, complete the client, and run it."

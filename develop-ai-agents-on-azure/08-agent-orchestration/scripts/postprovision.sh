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
AZURE_AI_PROJECT_ENDPOINT=${PROJECT_ENDPOINT}
AZURE_AI_MODEL_DEPLOYMENT_NAME=${MODEL_DEPLOYMENT_NAME}
EOF
echo "Done. See README.md to install dependencies and run the exercise."

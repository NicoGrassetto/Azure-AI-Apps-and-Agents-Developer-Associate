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
cat > src/.env <<ENV
PROJECT_ENDPOINT=${PROJECT_ENDPOINT}
MODEL_DEPLOYMENT_NAME=${MODEL_DEPLOYMENT_NAME:-gpt-4o}
ENV
echo "Done. See README.md for the remaining (portal / tenant) steps and how to run the lab."

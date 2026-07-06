#!/usr/bin/env sh
# Post-provision setup: create a Python virtual environment, install
# dependencies, write src/.env from azd outputs, and create the agent with its
# grounding data. Invoked automatically by `azd up`; safe to run by hand too.
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$ROOT"

PYTHON_BIN=${PYTHON_BIN:-python3}
VENV_DIR="$ROOT/.venv"

if [ ! -d "$VENV_DIR" ]; then
  echo "Creating virtual environment (.venv)..."
  "$PYTHON_BIN" -m venv "$VENV_DIR"
fi
# shellcheck disable=SC1091
. "$VENV_DIR/bin/activate"

echo "Installing Python dependencies..."
python -m pip install --quiet --upgrade pip
python -m pip install --quiet -r src/requirements.txt

if [ -n "${PROJECT_ENDPOINT:-}" ]; then
  echo "Writing src/.env from azd outputs..."
  {
    echo "PROJECT_ENDPOINT=${PROJECT_ENDPOINT}"
    echo "AGENT_NAME=${AGENT_NAME:-it-support-agent}"
    echo "MODEL_DEPLOYMENT_NAME=${MODEL_DEPLOYMENT_NAME:-gpt-4o}"
  } > src/.env
fi

echo "Creating the agent and uploading grounding data..."
cd src
python setup_agent.py

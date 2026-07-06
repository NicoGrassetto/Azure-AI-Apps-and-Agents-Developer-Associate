"""Provision the IT Support Agent and its grounding data.

This script automates the manual Foundry-portal steps from the original lab:

  * uploads the IT policy document and builds a vector store for File Search
  * uploads the system performance CSV for the Code Interpreter
  * creates (or versions) a prompt agent that uses both tools

It is invoked automatically by ``azd up`` (postprovision hook) but can also be
run by hand:

    python setup_agent.py

Requires PROJECT_ENDPOINT and MODEL_DEPLOYMENT_NAME in the environment or a
local .env file, plus an authenticated Azure session (``az login`` /
``azd auth login``).
"""

import os
import sys
import time
from pathlib import Path

from azure.ai.projects import AIProjectClient
from azure.ai.projects.models import (
    AutoCodeInterpreterToolParam,
    CodeInterpreterTool,
    FileSearchTool,
    PromptAgentDefinition,
)
from azure.core.exceptions import ClientAuthenticationError, HttpResponseError
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv

DATA_DIR = Path(__file__).resolve().parent.parent / "data"
POLICY_FILE = DATA_DIR / "IT_Policy.txt"
PERFORMANCE_FILE = DATA_DIR / "system_performance.csv"

INSTRUCTIONS = """You are an IT Support Agent for Contoso Corporation.
You help employees with technical issues and IT policy questions.

Guidelines:
- Always be professional and helpful.
- Use the IT policy documentation to answer policy questions accurately.
- Use the performance data with the code interpreter to analyze metrics and create charts on request.
- If you do not know an answer, say so and suggest contacting IT support directly.
- When creating a support ticket, collect all necessary information before proceeding.
"""


def with_retries(action, *, description, attempts=8, delay=15):
    """Run an action, retrying on auth errors while RBAC role assignments propagate."""
    for attempt in range(1, attempts + 1):
        try:
            return action()
        except (ClientAuthenticationError, HttpResponseError) as error:
            status = getattr(error, "status_code", None)
            if status not in (401, 403) and attempt > 1:
                raise
            if attempt == attempts:
                raise
            print(
                f"  {description} not ready yet (attempt {attempt}/{attempts}); "
                f"waiting {delay}s for permissions to propagate..."
            )
            time.sleep(delay)


def upload_file(openai_client, path: Path):
    print(f"Uploading {path.name}...")
    with path.open("rb") as handle:
        return openai_client.files.create(file=handle, purpose="assistants")


def build_vector_store(openai_client, file_id: str):
    print("Creating vector store for File Search...")
    vector_store = openai_client.vector_stores.create(
        name="it-policy-knowledge",
        file_ids=[file_id],
    )
    for _ in range(30):
        current = openai_client.vector_stores.retrieve(vector_store.id)
        if getattr(current, "status", None) == "completed":
            break
        time.sleep(2)
    return vector_store


def main() -> int:
    load_dotenv()
    project_endpoint = os.environ.get("PROJECT_ENDPOINT")
    model_deployment = os.environ.get("MODEL_DEPLOYMENT_NAME", "gpt-4o")
    agent_name = os.environ.get("AGENT_NAME", "it-support-agent")

    if not project_endpoint:
        print("Error: PROJECT_ENDPOINT is not set. Run `azd up` or set it in .env.")
        return 1

    for data_file in (POLICY_FILE, PERFORMANCE_FILE):
        if not data_file.exists():
            print(f"Error: missing data file {data_file}")
            return 1

    print(f"Connecting to Foundry project: {project_endpoint}")
    project_client = AIProjectClient(
        credential=DefaultAzureCredential(),
        endpoint=project_endpoint,
    )
    openai_client = project_client.get_openai_client()

    policy_file = with_retries(
        lambda: upload_file(openai_client, POLICY_FILE),
        description="Data-plane access",
    )
    vector_store = build_vector_store(openai_client, policy_file.id)
    performance_file = upload_file(openai_client, PERFORMANCE_FILE)

    definition = PromptAgentDefinition(
        model=model_deployment,
        instructions=INSTRUCTIONS,
        tools=[
            FileSearchTool(vector_store_ids=[vector_store.id]),
            CodeInterpreterTool(
                container=AutoCodeInterpreterToolParam(
                    type="auto",
                    file_ids=[performance_file.id],
                )
            ),
        ],
    )

    print(f"Creating agent '{agent_name}'...")
    version = project_client.agents.create_version(
        agent_name=agent_name,
        definition=definition,
        description="IT Support Agent with File Search and Code Interpreter.",
    )

    print("\n" + "=" * 60)
    print(f"Agent '{agent_name}' is ready (version {getattr(version, 'version', 'n/a')}).")
    print("Grounding data uploaded: IT_Policy.txt, system_performance.csv")
    print("Run `python agent_with_functions.py` to chat with it.")
    print("=" * 60)
    return 0


if __name__ == "__main__":
    sys.exit(main())

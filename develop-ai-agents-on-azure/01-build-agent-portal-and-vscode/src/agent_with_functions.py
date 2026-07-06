"""Interactive command-line client for the IT Support Agent.

Connects to a Microsoft Foundry project, loads a previously created agent by
name, and runs a chat loop against it using the Responses API. Any files or
charts the agent produces (for example via the code interpreter) are downloaded
into the local ``agent_outputs`` directory.

Usage:
    python agent_with_functions.py

Requires PROJECT_ENDPOINT and AGENT_NAME to be set in the environment or a
local .env file. Run ``az login`` (or ``azd auth login``) first so that
DefaultAzureCredential can authenticate.
"""

import base64
import os
from pathlib import Path

from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential
from dotenv import load_dotenv

OUTPUT_DIR = Path("agent_outputs")


def unique_output_path(filename: str) -> Path:
    """Return a non-colliding path inside OUTPUT_DIR for the given filename."""
    OUTPUT_DIR.mkdir(exist_ok=True)
    name = Path(filename).name
    stem, suffix = Path(name).stem or "output", Path(name).suffix
    candidate = OUTPUT_DIR / name
    counter = 1
    while candidate.exists():
        candidate = OUTPUT_DIR / f"{stem}_{counter}{suffix}"
        counter += 1
    return candidate


def write_bytes(data: bytes, filename: str) -> Path:
    path = unique_output_path(filename)
    path.write_bytes(data)
    return path


def fetch_container_file(openai_client, annotation, cache: dict) -> Path:
    """Download a code-interpreter container file once, caching by id."""
    key = (annotation.container_id, annotation.file_id)
    if key not in cache:
        content = openai_client.containers.files.content.retrieve(
            file_id=annotation.file_id,
            container_id=annotation.container_id,
        )
        cache[key] = write_bytes(
            content.read(), annotation.filename or f"{annotation.file_id}.bin"
        )
    return cache[key]


def render_text(content_item, openai_client, cache: dict):
    """Return the message text with sandbox citations replaced by local paths."""
    text = content_item.text or ""
    saved = set()
    spans = []

    for annotation in getattr(content_item, "annotations", None) or []:
        if getattr(annotation, "type", "") != "container_file_citation":
            continue
        local_path = fetch_container_file(openai_client, annotation, cache)
        saved.add(local_path)
        replacement = f"{annotation.filename} (saved to {local_path})"

        start, end = getattr(annotation, "start_index", None), getattr(annotation, "end_index", None)
        if start is not None and end is not None:
            spans.append((start, end, replacement))
        elif getattr(annotation, "text", ""):
            text = text.replace(annotation.text, replacement)

    for start, end, replacement in sorted(spans, reverse=True):
        text = f"{text[:start]}{replacement}{text[end:]}"

    return text, saved


def print_response(response, openai_client) -> None:
    """Print the agent's reply and persist any generated files/charts."""
    cache: dict = {}
    referenced = set()
    printed = False
    image_count = 0

    for item in getattr(response, "output", None) or []:
        item_type = getattr(item, "type", "")

        if item_type == "message":
            for content_item in getattr(item, "content", None) or []:
                if getattr(content_item, "type", "") != "output_text":
                    continue
                text, saved = render_text(content_item, openai_client, cache)
                referenced |= saved
                if text:
                    print(f"\nAgent: {text}\n")
                    printed = True

        elif item_type == "image":
            image_count += 1
            image = getattr(item, "image", None)
            if image is not None and getattr(image, "data", None):
                path = write_bytes(base64.b64decode(image.data), f"chart_{image_count}.png")
                print(f"\n[Agent generated a chart - saved to: {path}]")
            else:
                print("\n[Agent generated an image]")
            printed = True

        elif getattr(item, "text", None):
            print(f"\nAgent: {item.text}\n")
            printed = True

    for path in cache.values():
        if path not in referenced:
            print(f"\n[Agent generated a file - saved to: {path}]")
            printed = True

    if not printed and getattr(response, "output_text", None):
        print(f"\nAgent: {response.output_text}\n")


def main() -> None:
    load_dotenv()
    project_endpoint = os.environ.get("PROJECT_ENDPOINT")
    agent_name = os.environ.get("AGENT_NAME", "it-support-agent")

    if not project_endpoint:
        print("Error: PROJECT_ENDPOINT is not set. Add it to your .env file or run `azd up`.")
        return

    print("Connecting to Microsoft Foundry project...")
    project_client = AIProjectClient(
        credential=DefaultAzureCredential(),
        endpoint=project_endpoint,
    )
    openai_client = project_client.get_openai_client()

    print(f"Loading agent: {agent_name}")
    agent = project_client.agents.get(agent_name=agent_name)
    print(f"Connected to agent: {agent.name}")

    conversation = openai_client.conversations.create(items=[])

    print("\n" + "=" * 60)
    print("IT Support Agent ready. Ask a question, request data analysis,")
    print("or type 'exit' to quit.")
    print("=" * 60 + "\n")

    while True:
        try:
            user_input = input("You: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGoodbye!")
            break

        if user_input.lower() in {"exit", "quit", "bye"}:
            print("Goodbye!")
            break
        if not user_input:
            continue

        openai_client.conversations.items.create(
            conversation_id=conversation.id,
            items=[{"type": "message", "role": "user", "content": user_input}],
        )

        print("\n[Agent is thinking...]")
        response = openai_client.responses.create(
            conversation=conversation.id,
            extra_body={"agent_reference": {"name": agent.name, "type": "agent_reference"}},
            input="",
        )
        print_response(response, openai_client)


if __name__ == "__main__":
    main()

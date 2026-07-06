# Exercise 02 — Use custom tools with an agent

An astronomy assistant agent that calls custom Python **function tools** (look up events, compute observation costs, and generate a report).

> **Official exercise:** [02-agent-custom-tools.html](https://microsoftlearning.github.io/mslearn-ai-agents/Instructions/Exercises/02-agent-custom-tools.html)
> **Source & license:** MIT — [MicrosoftLearning/mslearn-ai-agents](https://github.com/MicrosoftLearning/mslearn-ai-agents). See [ATTRIBUTION.md](./ATTRIBUTION.md).

## About the code in `src/`

The Python files in `src/` are the lab's **guided starter templates** exactly
as shipped by Microsoft Learning (they contain `# Add references` / `# TODO`
placeholders). You complete them by following the official exercise linked
above. This folder adds the missing piece: **the Azure infrastructure is
provisioned for you with `azd up`** instead of by hand in the portal.

## What `azd up` provisions (`infra/`)

| Resource | Notes |
| --- | --- |
| Azure AI Foundry account (`AIServices`, project management enabled) | data plane used by the agents |
| Foundry project | organizes agents/models |
| `gpt-4o` model deployment | override with `MODEL_NAME` / `MODEL_VERSION` azd env vars (upstream lab uses `gpt-5`) |
| Data-plane role assignments for your signed-in user | Azure AI Developer, Cognitive Services (OpenAI) User |

The postprovision hook writes `src/.env` from the deployment outputs.

## Prerequisites

- An [Azure subscription](https://azure.microsoft.com/free/) with model quota
- [Azure Developer CLI (`azd`)](https://aka.ms/azd-install) and [Azure CLI (`az`)](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Python 3.10+](https://www.python.org/downloads/)

## Quickstart

```bash
# 1. Provision Azure resources (writes src/.env automatically)
azd auth login
az login
azd up

# 2. Install dependencies
python -m venv .venv
source .venv/bin/activate            # Windows: .venv\Scripts\Activate.ps1
pip install -r src/requirements.txt

# 3. Complete the guided code by following the official exercise, then run:
cd src && python agent.py
```

## Clean up

```bash
azd down --purge
```

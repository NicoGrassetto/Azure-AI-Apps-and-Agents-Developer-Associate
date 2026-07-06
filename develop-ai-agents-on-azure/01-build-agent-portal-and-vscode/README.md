# Exercise 01 — Build AI agents with portal and VS Code

An IT Support Agent for the fictional **Contoso Corporation** that answers IT
policy questions (via **File Search** over a policy document) and analyzes
system telemetry (via the **Code Interpreter** over a CSV of performance data).

This folder is a self-contained, Infrastructure-as-Code version of the Microsoft
Learn lab. Instead of clicking through the Foundry portal to create the project,
model, agent, and grounding data, everything is provisioned and configured with
**`azd up`** plus one command to start chatting.

> Based on the MIT-licensed lab
> [Build AI agents with portal and VS Code](https://microsoftlearning.github.io/mslearn-ai-agents/Instructions/Exercises/01-build-agent-portal-and-vscode.html)
> from [MicrosoftLearning/mslearn-ai-agents](https://github.com/MicrosoftLearning/mslearn-ai-agents).
> See [ATTRIBUTION.md](./ATTRIBUTION.md).

## What gets created

| Component | Provisioned by |
| --- | --- |
| Azure AI Foundry account (`AIServices`, project management enabled) | `infra/` Bicep |
| Foundry project | `infra/` Bicep |
| `gpt-4o` model deployment | `infra/` Bicep |
| Data-plane role assignments for your user | `infra/` Bicep |
| `it-support-agent` with File Search + Code Interpreter | `scripts/setup` → `src/setup_agent.py` |
| Grounding data (IT policy + performance CSV) uploaded | `scripts/setup` → `src/setup_agent.py` |

## Prerequisites

- An [Azure subscription](https://azure.microsoft.com/free/) with quota to deploy `gpt-4o`
- [Azure Developer CLI (`azd`)](https://aka.ms/azd-install)
- [Azure CLI (`az`)](https://learn.microsoft.com/cli/azure/install-azure-cli)
- [Python 3.10+](https://www.python.org/downloads/)

## Quickstart

From this folder:

```bash
# 1. Sign in
azd auth login
az login

# 2. Provision infra + create the agent + upload grounding data
azd up
```

`azd up` prompts for an environment name and region, deploys the Bicep in
`infra/`, then runs the postprovision hook which:

1. creates a local `.venv` and installs `src/requirements.txt`,
2. writes `src/.env` from the deployment outputs, and
3. runs `src/setup_agent.py` to create the agent and upload grounding data.

Then start the interactive client:

```bash
# macOS / Linux
source .venv/bin/activate
cd src && python agent_with_functions.py
```

```powershell
# Windows (PowerShell)
.venv\Scripts\Activate.ps1
cd src ; python agent_with_functions.py
```

## Try these prompts

```text
What's the policy for password resets?
How do I request new software?
Analyze the system performance data and identify any periods where CPU usage exceeded 80%.
Create a line chart showing memory usage trends over time.
```

Charts and files the agent generates are saved to `src/agent_outputs/` and the
local path is printed in the terminal. Type `exit` to quit.

## Project layout

```
01-build-agent-portal-and-vscode/
├── azure.yaml                 # azd project (infra + postprovision hook)
├── infra/
│   ├── main.bicep             # subscription scope: RG + Foundry + model + RBAC
│   ├── main.parameters.json
│   └── modules/ai-foundry.bicep
├── scripts/
│   ├── setup.sh               # postprovision (macOS/Linux)
│   └── setup.ps1              # postprovision (Windows)
├── src/
│   ├── agent_with_functions.py  # interactive chat client
│   ├── setup_agent.py           # creates the agent + uploads grounding data
│   ├── requirements.txt
│   └── .env.example
└── data/
    ├── IT_Policy.txt            # grounding doc for File Search
    └── system_performance.csv   # dataset for Code Interpreter
```

## Re-run the setup only

If provisioning already succeeded and you only want to (re)create the agent:

```bash
source .venv/bin/activate
cd src && python setup_agent.py
```

## Clean up

```bash
azd down --purge
```

This deletes the resource group and purges the soft-deleted Foundry account so
you are not billed for idle resources.

## Prefer the manual portal walkthrough?

The original step-by-step lab (create everything by hand in the Foundry portal
and the VS Code Foundry Toolkit) is still available
[here](https://microsoftlearning.github.io/mslearn-ai-agents/Instructions/Exercises/01-build-agent-portal-and-vscode.html).
The Python client in `src/` works the same way regardless of whether the agent
was created by `azd` or by hand — just set `PROJECT_ENDPOINT` and `AGENT_NAME`
in `src/.env`.

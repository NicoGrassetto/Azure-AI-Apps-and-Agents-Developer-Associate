# Exercise 05a — Deploy agents to Microsoft Teams and Copilot

Publish an AI agent to **Microsoft Teams** and **Microsoft 365 Copilot**. This
folder provisions the Foundry project + model with `azd up`; the agent creation,
knowledge grounding, and Teams/M365 publishing are done in the Foundry portal and
your Microsoft 365 tenant (these steps are tenant-bound and can't be expressed in
Bicep).

> Official instructions:
> https://microsoftlearning.github.io/mslearn-ai-agents/Instructions/Exercises/05a-m365-teams-integration.html

## What `azd up` provisions

`infra/` (Bicep, subscription scope) creates a resource group `rg-<env>` with an
**Azure AI Foundry** account + **project**, a **chat model** deployment (default
`gpt-4o`), and the RBAC your signed-in user needs. The `postprovision` hook writes
`src/.env` with `PROJECT_ENDPOINT` and `MODEL_DEPLOYMENT_NAME`.

## Prerequisites for the manual steps

- A **Microsoft 365 account** with Teams access (for Teams publishing).
- A **Microsoft 365 Copilot license** (optional — only for Copilot publishing).
- The **Teams admin** may need to approve custom/uploaded apps in your tenant.

## Quickstart

```bash
# 1. Provision the Foundry project + model
azd up

# 2. (Optional) explore the lab helper scripts
cd src
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
python check_prerequisites.py       # verify az / azd / python tooling
python setup_search.py              # optional: create Azure AI Search + index the sample_documents
python m365_teams_lab.py            # interactive walkthrough of the integration patterns
```

## Manual steps (portal + tenant)

These follow the official instructions and cannot be automated with `azd`:

1. In the Foundry portal for your provisioned project, create the agent and add
   knowledge grounding using the files in `src/sample_documents/`.
2. **Publish to Teams**: from the agent, choose **Publish → Publish to Teams and
   Microsoft 365 Copilot**. The portal generates a Teams app manifest; supply the
   two required app icons and the app details.
3. Install/side-load the generated Teams app (a tenant admin may need to approve
   it), then chat with the agent in Teams.
4. For **Microsoft 365 Copilot**, publishing requires an M365 Copilot license.

`cleanup_all.py` (or `azd down --purge`) removes the Azure resources.

## Choosing the model

Upstream references `gpt-5`. This template defaults to `gpt-4o`. Override before
`azd up` with `azd env set MODEL_NAME gpt-5` (and `MODEL_VERSION`) if you have
quota.

See `ATTRIBUTION.md` for source and license. The Python files are Microsoft's lab
helpers/skeletons — complete and run them per the official instructions.

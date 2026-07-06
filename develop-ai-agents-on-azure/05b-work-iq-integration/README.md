# Exercise 05b — Integrate an agent with Work IQ

Build an agent that accesses your **Microsoft 365 workplace data** (emails,
meetings, Teams chats) through **Work IQ** — Microsoft's contextual intelligence
layer built on the **Model Context Protocol (MCP)**. This folder provisions the
Foundry project + model with `azd up`; Work IQ access itself is tenant-bound and
requires an M365 Copilot license and IT-admin consent, so those steps stay manual.

> Official instructions:
> https://microsoftlearning.github.io/mslearn-ai-agents/Instructions/Exercises/05b-work-iq-integration.html

> **Optional / advanced lab.** It requires a **Microsoft 365 Copilot license** and
> works only for enterprise accounts with access to live M365 data. Standard M365
> accounts without Copilot will not work.

## What `azd up` provisions

`infra/` (Bicep, subscription scope) creates a resource group `rg-<env>` with an
**Azure AI Foundry** account + **project**, a **chat model** deployment (default
`gpt-4o`), and the RBAC your signed-in user needs. The `postprovision` hook writes
`src/.env` with `PROJECT_ENDPOINT` and `MODEL_DEPLOYMENT_NAME`.

## Prerequisites for the manual steps

- **Microsoft 365 Copilot license** (organizational or personal-with-Copilot).
- **IT-admin approval / admin consent** for Work IQ on organizational accounts.
- Active M365 data (emails, meetings, Teams chats) to query.

## Quickstart

```bash
# 1. Provision the Foundry project + model
azd up

# 2. Run the Work IQ lab
cd src
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
python workiq_lab.py
```

## Manual steps (tenant / admin)

These follow the official instructions and cannot be automated with `azd`:

1. Ensure your account has an **M365 Copilot license**.
2. On first connection to the Work IQ MCP endpoint you may see **"Admin consent
   required"** — send the consent URL to your IT administrator and retry after
   approval.
3. The combined scenario (Work IQ **and** Foundry IQ together) additionally needs
   **Azure AI Search** configured with an indexed knowledge base in your Foundry
   project — see exercise 04 for the Foundry IQ setup.

`azd down --purge` removes the Azure resources.

## Choosing the model

Upstream references `gpt-5`. This template defaults to `gpt-4o`. Override before
`azd up` with `azd env set MODEL_NAME gpt-5` (and `MODEL_VERSION`) if you have
quota.

See `ATTRIBUTION.md` for source and license. `workiq_lab.py` is Microsoft's lab
skeleton — complete and run it per the official instructions.

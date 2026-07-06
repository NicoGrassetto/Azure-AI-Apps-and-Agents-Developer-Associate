# Exercise 04 — Integrate an AI agent with Foundry IQ

Build a **product-expert agent** that answers questions from a grounded knowledge
base using **Foundry IQ** (Azure AI Search + Azure Blob Storage + an embedding
model). This folder provisions all the cloud resources with `azd up`, then you
finish the knowledge base and agent in the Foundry portal and complete the Python
client.

> Official instructions:
> https://microsoftlearning.github.io/mslearn-ai-agents/Instructions/Exercises/04-integrate-agent-with-foundry-iq.html

## What `azd up` provisions

`infra/` (Bicep, subscription scope) creates a resource group `rg-<env>` with:

- **Azure AI Foundry** account (`AIServices`) + a **project**
- A **chat model** deployment (default `gpt-4o`) for the agent
- An **embedding model** deployment (default `text-embedding-3-small`) used to
  vectorize documents
- An **Azure AI Search** service (Standard, semantic ranking enabled)
- An **Azure Storage** account + `product-data` blob container for the source docs
- **RBAC**: your user gets Azure AI Developer, Cognitive Services OpenAI User /
  User, Search Service Contributor, Search Index Data Contributor, and Storage
  Blob Data Contributor. The Search identity gets read access to Storage and to
  the embedding model; the Foundry project identity gets read access to Search.

The `postprovision` hook writes `src/.env` with `PROJECT_ENDPOINT`, `AGENT_NAME`,
and reference values (search/storage/embedding names) for the portal steps.

> Foundry IQ knowledge bases and agents are created through the portal wizard, so
> that part isn't expressed in Bicep — but every resource the wizard needs is
> pre-provisioned, so it's just a few clicks.

## Quickstart

```bash
# 1. Provision everything
azd up          # pick a region such as eastus2 or swedencentral

# 2. Upload the sample product docs to the provisioned container
#    (values are in src/.env after provisioning)
az storage blob upload-batch \
  --account-name "$STORAGE_ACCOUNT_NAME" \
  --destination product-data \
  --source ./data \
  --pattern "*.md" \
  --auth-mode login

# 3. Create the knowledge base + agent in the portal (see below), then:
cd src
python -m venv .venv && source .venv/bin/activate   # Windows: .venv\Scripts\Activate.ps1
pip install -r requirements.txt
python agent_client.py
```

### Configure the knowledge base + agent (portal)

Following the official instructions, in the Foundry portal for your provisioned
project:

1. Create an agent named **`product-expert-agent`** (matches `AGENT_NAME`) and
   give it the product-expert system prompt from the instructions.
2. In **Knowledge → Add → Connect to Foundry IQ**, connect to the **Azure AI
   Search** resource this template created (`SEARCH_SERVICE_NAME` in `src/.env`).
3. Create a knowledge base from **Azure Blob Storage**, pointing at the
   `product-data` container you uploaded in step 2 above, and select the
   **`text-embedding-3-small`** embedding deployment.

Then complete the `TODO` blocks in `src/agent_client.py` (connect the project
client, get the agent by name, create a conversation, send messages and print
citations) as described in the exercise, and run it.

## Choosing the model

Upstream references `gpt-5`. This template defaults to `gpt-4o` for broad
availability. Override before `azd up` if you have `gpt-5` quota:

```bash
azd env set MODEL_NAME gpt-5
azd env set MODEL_VERSION <version>
```

## Clean up

```bash
azd down --purge
```

See `ATTRIBUTION.md` for source and license.

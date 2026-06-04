# PSConfEU – Azure Function Group Manager

A PowerShell Azure Function App that manages Entra ID (Azure AD) security groups and their members via the Microsoft Graph API. Built for the PSConfEU session on serverless PowerShell automation.

Credits to https://gitlab.com/rokicool/azure-function-app

---

## What it does

Two HTTP-triggered endpoints expose a simple REST API for group management:

### `/api/Group`

| Method | Body / Query | Description |
|--------|-------------|-------------|
| GET | `?GroupId=<guid>` or body `{ "GroupId": "..." }` | Look up a group by ID |
| POST | `{ "Name": "..." }` | Create a new security group |
| DELETE | `?GroupId=<guid>` or body `{ "GroupId": "..." }` | Delete a group |

### `/api/GroupMember`

| Method | Body | Description |
|--------|------|-------------|
| GET | `?GroupId=<guid>` or body `{ "GroupId": "..." }` | List all user members of a group |
| POST | `{ "GroupId": "...", "UserPrincipalName": "..." }` | Add a user to a group |
| DELETE | `{ "GroupId": "...", "UserPrincipalName": "..." }` | Remove a user from a group |

Authentication uses the Function App's **system-assigned Managed Identity** — no credentials are stored in code.

---

## Prerequisites

- Azure subscription
- Azure Function App (PowerShell 7.4 runtime, Windows or Linux)
- System-assigned Managed Identity enabled on the Function App
- The Managed Identity granted the following **Microsoft Graph application permissions**:
  - `Group.ReadWrite.All`
  - `GroupMember.ReadWrite.All`
  - `User.Read.All`

---

## GitHub Actions CI/CD setup

The pipeline in `.github/workflows/deploy.yml` builds and deploys on every push to `main`.

### Secrets (Settings → Secrets and variables → Actions → Secrets)

| Secret | Description |
|--------|-------------|
| `AZURE_CLIENT_ID` | Client ID of the service principal used for deployment |
| `AZURE_TENANT_ID` | Azure AD tenant ID |
| `AZURE_SUBSCRIPTION_ID` | Azure subscription ID |

The pipeline uses OIDC (federated credentials) for the Azure login step — no client secret is needed. Make sure the service principal has the **Contributor** role on the Function App or resource group, and has a federated credential configured for the GitHub repo and `main` branch.

### Variables (Settings → Secrets and variables → Actions → Variables)

| Variable | Description |
|----------|-------------|
| `AZURE_AZFUNC_NAME` | Name of the Azure Function App (e.g. `my-function-app`) |
| `AZURE_RESOURCE_GROUP` | Name of the resource group the Function App lives in |

---

## Local development

### Requirements

- [PowerShell 7+](https://github.com/PowerShell/PowerShell/releases)
- [Azure Functions Core Tools v4](https://learn.microsoft.com/en-us/azure/azure-functions/functions-run-local)

### Install module dependencies

```powershell
pwsh ./azure-function/Modules/installModules.ps1
```

This installs the required Graph and Az modules and copies them into `azure-function/Modules/` so they are bundled into the deployment package.

### Run locally

```powershell
cd azure-function
func start
```

---
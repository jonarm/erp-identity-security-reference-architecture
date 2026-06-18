# Terraform — ERP Identity Security Reference Architecture

*Author: Jonar | Repository: [jonarm](https://github.com/jonarm)*

---

## Overview

This directory contains Infrastructure-as-Code (IaC) for deploying 
the Zero Trust identity security architecture for Contoso Financial 
Services' Dynamics 365 ERP environment.

All Azure and Entra ID resources are managed via Terraform using the 
`hashicorp/azurerm` and `hashicorp/azuread` providers — ensuring 
every configuration change is version-controlled, peer-reviewable, 
and repeatable across environments.

---

## What Gets Deployed

| File | Resources Created |
|---|---|
| `main.tf` | Azure provider config, resource group |
| `entra-enterprise-app.tf` | D365 app registration, service principal |
| `entra-app-roles.tf` | 9 ERP functional role definitions |
| `conditional-access.tf` | 6 Conditional Access policies |
| `pim.tf` | PIM eligible role assignments |
| `variables.tf` | Input variable definitions |

---

## Architecture Deployed
Entra ID Tenant

├── App Registration — Contoso Financial Services - Dynamics 365

│   ├── SAML SSO configuration

│   ├── App roles (9 ERP functional roles)

│   └── Service principal (assignment required = true)

│

├── Conditional Access Policies (6)

│   ├── CA001 - Require MFA for All Users

│   ├── CA002 - Block Legacy Authentication

│   ├── CA003 - Require Compliant Device (report-only)

│   ├── CA004 - Sign-in Risk Step-Up Authentication

│   ├── CA005 - ERP Admin PIM Role Protection (report-only)

│   └── CA006 - MCAS Session Control for Unmanaged Devices

│

└── PIM Eligible Assignments

├── Global Administrator — eligible only

└── Application Administrator — eligible only
Azure Subscription

└── Resource Group — rg-erp-security-lab

└── Log Analytics Workspace — law-erp-sentinel

└── Microsoft Sentinel

---

## Prerequisites

| Tool | Version | Install |
|---|---|---|
| Terraform | >= 1.5.0 | [terraform.io/downloads](https://terraform.io/downloads) |
| Azure CLI | Latest | [docs.microsoft.com/cli/azure](https://docs.microsoft.com/cli/azure/install-azure-cli) |
| PowerShell | >= 7.0 | [github.com/PowerShell](https://github.com/PowerShell/PowerShell) |

### Required Azure Permissions

The service principal running Terraform requires:

| Permission | Where | Why |
|---|---|---|
| Contributor | Azure Subscription | Create resource group and workspace |
| Application Administrator | Entra ID | Create app registrations and service principals |
| Conditional Access Administrator | Entra ID | Create and manage CA policies |
| Privileged Role Administrator | Entra ID | Configure PIM assignments |

---

## Setup

### 1. Clone the Repository

```bash
git clone https://github.com/jonarm/erp-identity-security-reference-architecture
cd erp-identity-security-reference-architecture/terraform
```

### 2. Create a Service Principal

```powershell
az login

az ad sp create-for-rbac `
  --name "sp-terraform-erp-lab" `
  --role "Contributor" `
  --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

Copy the output — you will need `appId`, `password`, and `tenant`.

### 3. Grant Entra ID Permissions to the Service Principal

In **entra.microsoft.com → App registrations → sp-terraform-erp-lab → API permissions**:

Add these Microsoft Graph application permissions and grant admin consent:
Policy.Read.All

Policy.ReadWrite.ConditionalAccess

RoleManagement.ReadWrite.Directory

RoleEligibilitySchedule.ReadWrite.Directory

Application.ReadWrite.All

Directory.ReadWrite.All

### 4. Create terraform.tfvars

Create `terraform/terraform.tfvars` — this file is gitignored and must never be committed:

```hcl
tenant_id       = "your-entra-tenant-id"
subscription_id = "your-azure-subscription-id"
client_id       = "your-service-principal-app-id"
client_secret   = "your-service-principal-password"
erp_admin_upn   = "admin@yourtenant.onmicrosoft.com"
```

### 5. Initialise Terraform

```powershell
cd terraform
terraform init
```

Expected output:
Terraform has been successfully initialized!

---

## Deployment

### Preview Changes

```powershell
terraform plan
```

Review the planned changes carefully before applying.

### Deploy

```powershell
terraform apply
```

Type `yes` when prompted. Deployment takes approximately 3-5 minutes.

### Expected Output
Apply complete! Resources: 11 added, 0 changed, 0 destroyed.
Outputs:

erp_app_client_id        = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

erp_app_object_id        = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

erp_service_principal_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

---

## Resource Verification

After deployment verify these resources exist:

**Entra ID — App Registrations:**
1. Go to **entra.microsoft.com → App registrations → All applications**
2. Search **Contoso Financial Services**
3. Verify App roles tab shows all 9 roles

**Entra ID — Conditional Access:**
1. Go to **entra.microsoft.com → Protection → Conditional Access → Policies**
2. Verify all 6 CA policies are listed

**Entra ID — PIM:**
1. Go to **entra.microsoft.com → Identity Governance → PIM**
2. → Microsoft Entra roles → Eligible assignments
3. Verify Global Administrator and Application Administrator show as eligible

**Azure — Resource Group:**
1. Go to **portal.azure.com → Resource groups → rg-erp-security-lab**
2. Verify Log Analytics workspace exists

---

## Important Notes

### Security Defaults

Microsoft enables Security Defaults on all new tenants. This must be 
disabled before Conditional Access policies can be enforced:

1. **entra.microsoft.com → Identity → Overview → Properties**
2. → **Manage security defaults → Disabled**
3. Reason: My organisation is using Conditional Access

### CA003 and CA005 — Report-Only Mode

CA003 (Require Compliant Device) and CA005 (ERP Admin Protection) 
are deployed in `enabledForReportingButNotEnforced` mode. This is 
intentional — enforcing device compliance before Intune enrolment 
will lock users out.

**To enforce after device enrolment:**

```hcl
# In conditional-access.tf
# Change state from:
state = "enabledForReportingButNotEnforced"
# To:
state = "enabled"
```

Then run `terraform apply`.

### Never Commit terraform.tfvars

The `terraform.tfvars` file contains sensitive credentials and is 
excluded via `.gitignore`. If accidentally committed:

1. Immediately rotate all credentials in Azure
2. Remove the file from git history using `git filter-branch`
3. Force push the cleaned history

---

## Destroying the Lab

To remove all Terraform-managed resources:

```powershell
terraform destroy
```

Type `yes` when prompted.

**Note:** The Log Analytics workspace and Sentinel instance were 
created manually and must be deleted separately via the Azure portal.

---

## Troubleshooting

| Error | Cause | Fix |
|---|---|---|
| `Security Defaults is enabled` | Security defaults not disabled | Disable via Entra ID portal first |
| `HostNameNotOnVerifiedDomain` | Identifier URI doesn't match tenant domain | Update `erp_app_identifier_uri` to use `yourtenant.onmicrosoft.com` |
| `Resource Provider registration failed` | Trial subscription limitation | Add `skip_provider_registration = true` to azurerm provider |
| `Resource Group already exists` | Manual creation before Terraform | Run `terraform import` to bring into state |
| `AccessDenied — scopes missing` | Service principal missing Graph permissions | Grant permissions via portal and re-run |
| `prevent_deletion_if_contains_resources` | Resource group has existing resources | Add `prevent_deletion_if_contains_resources = false` to features block |

---

## Related Documentation

- [Architecture Overview](../docs/architecture-overview.md)
- [ADR-001 SSO Protocol Selection](../docs/adr/ADR-001-sso-saml-vs-oidc.md)
- [ADR-002 PIM Configuration](../docs/adr/ADR-002-pim-for-erp-admin.md)
- [ADR-003 MCAS Session Controls](../docs/adr/ADR-003-mcas-session-controls.md)
- [ADR-004 SCIM Provisioning](../docs/adr/ADR-004-scim-vs-manual-provisioning.md)
- [Framework Mapping](../docs/framework-mapping.md)

---

*Last updated: June 2026 | Author: Jonar*
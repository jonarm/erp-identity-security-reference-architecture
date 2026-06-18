# Evidence Screenshots

*Author: Jonar | Repository: [jonarm](https://github.com/jonarm)*

All screenshots captured during live lab deployment and testing.
All user accounts, organisational data, and scenarios are fictitious
and used for educational and portfolio purposes only.

---

## Session 02 — Terraform Deployment

Screenshots confirming successful deployment of Entra ID app
registration and ERP role definitions via Terraform IaC.

| File | Description |
|---|---|
| `01-dynamics365-overview.png` | Entra ID app registration overview for Contoso Financial Services Dynamics 365 — shows Application ID, Object ID, and tenant confirmed after `terraform apply` |
| `02-dynamics365-approles.png` | All 9 ERP functional app roles deployed via Terraform — Finance User, Finance Manager, AP Officer, Payment Processor, Procurement Officer, Procurement Approver, Vendor Master Maintainer, Risk Auditor, ERP System Admin |
| `03-dynamics365-entapp-properties.png` | Enterprise application properties showing Assignment Required = Yes — ensures only explicitly assigned users can access the ERP application |

---

## Session 03 — Conditional Access Policies

Screenshots confirming all 6 Conditional Access policies deployed
and tested against a test user sign-in event.

### Policy Overview

| File | Description |
|---|---|
| `conditionalaccess-policies.png` | Full list of all 6 CA policies in Entra ID portal — CA001 through CA006 all visible with enabled or report-only state |
| `PIM-eligible-assignments.png` | PIM eligible assignments showing Global Administrator and Application Administrator assigned as eligible-only — no standing privileged access |

### CA001 — Require MFA for All Users

| File | Description |
|---|---|
| `CA001-mfa prompt.png` | Live MFA prompt firing during testfinanceuser sign-in — confirms CA001 is actively enforcing MFA for all authentication events |

### CA002 — Block Legacy Authentication

| File | Description |
|---|---|
| `CA002-conditionstab.png` | CA002 conditions tab showing client app types — Exchange ActiveSync and Other clients selected as the trigger condition |
| `CA002-granttab.png` | CA002 grant tab showing Block access control — any legacy authentication attempt is blocked entirely |

### CA003 — Require Compliant Device for ERP

| File | Description |
|---|---|
| `CA003-state-and-grant.png` | CA003 policy overview showing report-only state and grant controls requiring compliant device or domain joined device |
| `CA003-activitydetails.png` | Sign-in log Conditional Access tab showing CA003 evaluated in report-only mode during testfinanceuser sign-in |

### CA004 — Sign-in Risk Step-Up Authentication

| File | Description |
|---|---|
| `CA004-userrisk.png` | CA004 conditions tab showing user risk levels medium and high configured as trigger condition |
| `CA004-grant.png` | CA004 grant tab showing MFA required as the step-up control on risk detection |

### CA005 — ERP Admin PIM Role Protection

| File | Description |
|---|---|
| `CA005-policyoverview.png` | CA005 policy overview showing report-only state and Global Administrator role included as target |
| `CA005-grant.png` | CA005 grant tab showing MFA AND compliant device both required with AND operator — strictest control applied to admin roles |

### CA006 — MCAS Session Control for Unmanaged Devices

| File | Description |
|---|---|
| `CA006-session.png` | CA006 session controls configuration showing Use Conditional Access App Control with custom MCAS policy applied |
| `CA006-signinlog.png` | Sign-in log Conditional Access tab showing CA006 evaluated as Success with both Mfa and CloudAppSecurity controls applied — confirms unmanaged device session routing through MCAS |

---

## Session 04 — Microsoft Sentinel KQL Detection Rules

Screenshots confirming all 8 custom KQL analytics rules deployed
and a live incident generated from real sign-in activity.

### Analytics Rules

| File | Description |
|---|---|
| `01-sentinel-analytics-rules-all-8-enabled.png` | Microsoft Sentinel analytics rules list showing all 8 custom ERP detection rules deployed and enabled — covers MFA fatigue, impossible travel, bulk export, dormant account, admin outside hours, service account, credential stuffing, and privileged role assignment |
| `02-sentinel-rule-detail-credential-stuffing.png` | ERP Credential Stuffing rule detail showing KQL query, MITRE ATT&CK tactics (Initial Access, Credential Access), High severity, and T1110 technique mapping |

### Live Incident Evidence

| File | Description |
|---|---|
| `03-sentinel-incidents-list.png` | Sentinel incidents pane showing live ERP Credential Stuffing incident generated from real sign-in activity against the lab tenant |
| `04-sentinel-incident-credential-stuffing-overview.png` | Incident detail overview showing High severity, credential stuffing detection, affected entities, and incident timeline |
| `05-sentinel-incident-evidence-kql-results.png` | Incident evidence tab showing raw KQL query results that triggered the alert — displays alert details and matched conditions |
| `06-sentinel-kql-raw-evidence-credential-stuffing.png` | Log Analytics query output showing the full sign-in log evidence — 17 failed ResultType 50126 entries from same IP followed by 1 successful ResultType 500121 Browser login — matches credential stuffing kill chain |

---

## Session 05 — SOAR Playbooks and Attack Simulation

Screenshots confirming deployment of 3 Logic App SOAR playbooks
for automated incident response.

| File | Description |
|---|---|
| `01-logic-apps-deployed.png` | Azure resource group rg-erp-security-lab showing all 3 Logic App playbooks deployed — ERP-Revoke-Session, ERP-Notify-Admin-Activation, and ERP-Quarantine-Bulk-Export-User |
| `02-playbook-revoke-session-workflow.png` | ERP-Revoke-Session Logic App designer view showing automated workflow — Sentinel incident trigger → extract account entities → revoke all sessions via Graph API → add incident comment |
| `03-playbook-quarantine-workflow.png` | ERP-Quarantine-Bulk-Export-User Logic App designer view showing automated workflow — Sentinel incident trigger → extract account entities → disable account → revoke sessions → add quarantine comment → update incident status |

---

## Evidence Summary

| Session | Controls Demonstrated | Evidence Type |
|---|---|---|
| Terraform | App registration, 9 app roles, service principal | Portal screenshots post-deployment |
| Conditional Access | 6 CA policies, MFA enforcement, MCAS session control, PIM | Live sign-in log evaluation + policy config |
| Sentinel | 8 KQL detection rules, live incident, raw log evidence | Live incident + Log Analytics query results |
| SOAR Playbooks | 3 Logic App automated response workflows | Resource group deployment + workflow designer |

---

*Last updated: June 2026 | Author: Jonar*
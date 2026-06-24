# Zero Trust Identity Security for SaaS ERP
### Microsoft Dynamics 365 — Reference Architecture using Entra ID, Sentinel, and Defender for Cloud Apps

## Overview

This project demonstrates the design and implementation of a Zero Trust security architecture securing a Dynamics 365 Financial Services deployment. Built using Microsoft Sentinel, Entra ID P2, and Defender for Cloud Apps — deployed as Infrastructure-as-Code and mapped to the ACSC Essential Eight and Victorian Protective Data Security Standards (VPDSF).


The solution models a mid-sized financial services organisation and showcases how Microsoft security technologies can be combined to implement preventative, detective, and responsive controls across the identity lifecycle.

The project focuses on:

- Identity-centric security architecture
- Least privilege and Just-in-Time administration
- SaaS ERP access governance
- Security monitoring and detection engineering
- Automated incident response
- Infrastructure-as-Code deployment
- Compliance alignment with Australian government and industry security frameworks

The implementation is built using:

- Microsoft Entra ID P2
- Microsoft Sentinel
- Microsoft Defender for Cloud Apps
- Azure Logic Apps
- Terraform
- PowerShell

The architecture follows Zero Trust principles:

- Verify explicitly
- Use least privilege access
- Assume breach

All controls, detections, and response workflows are documented and mapped to recognised security frameworks including ACSC Essential Eight, VPDSF, NIST 800-207, ISO 27001, and MITRE ATT&CK.

---

## Key Outcomes

| Metric | Value |
|----------|----------|
| Conditional Access Policies | 6 |
| Sentinel Analytics Rules | 8 |
| SOAR Playbooks | 3 |
| Attack Simulations | 3 |
| Access Packages | 4 |
| Privileged Roles Protected by PIM | 7 |
| Simulated Users | 25 |
| Departments Modelled | 4 |
| Infrastructure-as-Code Coverage | 100% |

---
## Evidence

### Identity Controls
- Conditional Access policies: `docs/screenshots/conditional-access/`
- PIM configuration: `entra-id/pim-configuration/`
- Access packages: `entra-id/access-packages/`
- App roles: `entra-id/app-roles/`

### Detection Engineering
- Analytics rules: `sentinel/analytics-rules/`
- Sentinel screenshots: `docs/screenshots/sentinel/`
- Workbooks: `sentinel/workbooks/`

### SOAR Automation
- ERP Admin Activation Notification:
  `sentinel/playbooks/notify-erp-admin-activation/`

- Bulk Export User Quarantine:
  `sentinel/playbooks/quarantine-bulk-export-user/`

- ERP Session Revocation:
  `sentinel/playbooks/revoke-erp-session/`

### Infrastructure as Code
- Terraform deployment:
  `terraform/`

- Terraform screenshots:
  `docs/screenshots/terraform/`

### Attack Simulations
- MFA Fatigue:
  `attack-simulation/scenario-01-mfa-fatigue/`

- Dormant Account Reactivation:
  `attack-simulation/scenario-02-dormant-account-reactivation/`

- Bulk Data Exfiltration:
  `attack-simulation/scenario-03-bulk-data-exfiltration/`


---

## Architecture Overview

The architecture secures access to Microsoft Dynamics 365 through an identity-first security model.

### Security Layers

| Layer | Purpose |
|---------|---------|
| Entra ID | Authentication and identity governance |
| Conditional Access | Zero Trust access enforcement |
| PIM | Just-in-Time privileged access |
| Entitlement Management | Automated provisioning and lifecycle management |
| Defender for Cloud Apps | Session monitoring and SaaS activity controls |
| Sentinel | Detection engineering and incident monitoring |
| Logic Apps | Automated containment and response |
| Terraform | Infrastructure-as-Code deployment |

The architecture is designed to prevent, detect, and respond to common ERP attack scenarios including credential theft, privilege escalation, insider threats, and data exfiltration.

```mermaid
graph TD
    subgraph TENANT["FINANCIAL SERVICES TENANT"]

        ENTRA["Entra ID P2"]
        D365["Dynamics 365 F&O SaaS ERP"]

        ENTRA <-->|SSO/SAML| D365

        ENTRA --> CA

        subgraph CONTROLS["Identity Controls"]
            CA["Conditional Access 6 Policies"]
            PIM["PIM JIT Admin"]
            EM["Entitlement Management"]
        end

        CA --> SENTINEL

        subgraph SIEM["Detection and Response"]
            SENTINEL["Microsoft Sentinel SIEM\nEntra ID Logs | M365 Logs | Defender XDR Alerts\n8 Custom KQL Rules → 3 SOAR Playbooks"]
        end

        subgraph CASB["Session Security"]
            MCAS["Defender for Cloud Apps CASB\nSession Controls | Activity Policies | Anomaly"]
        end

    end

    classDef identity fill:#0078d4,stroke:#005a9e,color:#fff
    classDef erp fill:#107c10,stroke:#0a5c0a,color:#fff
    classDef monitoring fill:#8764b8,stroke:#6b4f9e,color:#fff
    classDef casb fill:#c43e1c,stroke:#a33519,color:#fff

    class ENTRA,CA,PIM,EM identity
    class D365 erp
    class SENTINEL monitoring
    class MCAS casb
```
---

## Threat Model

Threat modelling artifacts are available in:

`docs/erp-threat-model.md`

The threat model covers:

- Identity attack paths
- Privileged access abuse
- ERP data exfiltration
- Account takeover scenarios
- Joiner / Mover / Leaver control failures
- Zero Trust mitigations
- Detection and response mappings

---

## Simulated Organisation

| Attribute | Detail |
|---|---|
| **Organisation** | Contoso Financial Services (fictitious) |
| **Industry** | Financial Services |
| **ERP** | Microsoft Dynamics 365 Finance and Operations |
| **Users** | 25 across 4 departments |
| **Departments** | Finance, Procurement, IT, Risk & Compliance |
| **Deployment** | SaaS (Microsoft-hosted) |

### ERP Role Structure

| Role | Department | Sensitivity | Access Method |
|---|---|---|---|
| Finance User | Finance | Medium | Standard + MFA |
| Finance Manager | Finance | High | Compliant device + MFA |
| Procurement Officer | Procurement | Medium | Standard + MFA |
| Procurement Approver | Procurement | High | Compliant device + MFA |
| ERP System Admin | IT | Critical | PIM JIT + MFA + PAW |
| Risk Auditor | Risk & Compliance | High | Read-only + MFA |
| Global Admin | IT | Critical | PIM JIT + MFA + PAW |

---

## Security Controls Implemented

| Control | Implementation | Framework Mapping |
|---|---|---|
| MFA for all users | Entra ID CA Policy CA001 | Essential Eight ML2 |
| Block legacy authentication | CA Policy CA002 | Essential Eight ML1 |
| Compliant device for ERP | CA Policy CA003 | NIST 800-207 |
| Risk-based step-up auth | CA Policy CA004 | VPDSF ICT Security |
| ERP admin session protection | CA Policy CA005 | Essential Eight ML2 |
| Unmanaged device session control | CA Policy CA006 + MCAS | NIST 800-207 |
| JIT privileged access | PIM with approval workflow | Essential Eight ML3 |
| Automated user provisioning | SCIM + Entitlement Management | VPDSF Personnel Security |
| ERP threat detection | 8 custom Sentinel KQL rules | MITRE ATT&CK |
| Automated incident response | 3 Logic App SOAR playbooks | NIST CSF Respond |
| Bulk export detection | Defender for Cloud Apps policy | VPDSF Information Security |
| Segregation of duties | Entra ID app role constraints | ISO 27001 A.9 |

---

## Threat Scenarios

Full walkthroughs in [`attack-simulation/`](attack-simulation/)

### Scenario 1 — Insider Threat: Bulk Data Exfiltration
A Finance user with legitimate Dynamics 365 access begins exporting large volumes of supplier payment data ahead of their resignation. Defender for Cloud Apps detects the anomalous download volume. Sentinel fires the `erp-bulk-data-export` analytics rule. The SOAR playbook suspends the session and notifies the security team within minutes.

### Scenario 2 — Account Takeover via Credential Stuffing
An attacker uses a leaked credential list against the Dynamics 365 SSO login. Multiple failed attempts are followed by a successful login from an unusual location. The `erp-credential-stuffing` KQL rule fires in Sentinel. Conditional Access sign-in risk policy triggers step-up MFA automatically.

### Scenario 3 — Dormant Privileged Account Reactivation
A former ERP System Admin account is reactivated via a misconfigured HR sync. The `erp-dormant-account-activation` rule fires immediately. This scenario is used to demonstrate the joiner/mover/leaver control gap and the preventive role of automated offboarding.

---

## Architecture Decisions

| Decision | ADR |
|-----------|-----------|
| SAML vs OIDC Integration | `docs/adr/ADR-001-sso-saml-vs-oidc.md` |
| PIM for ERP Administrators | `docs/adr/ADR-002-pim-for-erp-admin.md` |
| MCAS Session Controls | `docs/adr/ADR-003-mcas-session-controls.md` |
| SCIM Provisioning Strategy | `docs/adr/ADR-004-scim-vs-manual-provisioning.md` |

---

## Repository Structure
```mermaid
graph LR
    ROOT["📁 erp-identity-security\nreference-architecture"]

    ROOT --> README["📄 README.md"]
    ROOT --> DOCS["📁 docs/"]
    ROOT --> TERRAFORM["📁 terraform/"]
    ROOT --> SENTINEL["📁 sentinel/"]
    ROOT --> ENTRAID["📁 entra-id/"]
    ROOT --> SCRIPTS["📁 scripts/"]
    ROOT --> ATTACK["📁 attack-simulation/"]

    %% Docs
    DOCS --> ARCH["📄 architecture-overview.md"]
    DOCS --> THREAT["📄 erp-threat-model.md"]
    DOCS --> LIFECYCLE["📄 identity-lifecycle.md"]
    DOCS --> SOD["📄 segregation-of-duties.md"]
    DOCS --> FRAMEWORK["📄 framework-mapping.md"]
    DOCS --> ADR["📁 adr/"]

    ADR --> ADR1["📄 ADR-001\nsso-saml-vs-oidc"]
    ADR --> ADR2["📄 ADR-002\npim-for-erp-admin"]
    ADR --> ADR3["📄 ADR-003\nmcas-session-controls"]
    ADR --> ADR4["📄 ADR-004\nscim-vs-manual-provisioning"]

    %% Sentinel
    SENTINEL --> RULES["📁 analytics-rules/"]
    SENTINEL --> WORKBOOKS["📁 workbooks/"]
    SENTINEL --> PLAYBOOKS["📁 playbooks/"]

    %% Entra ID
    ENTRAID --> CA["📁 conditional-access\n-policies/"]
    ENTRAID --> ROLES["📁 app-roles/"]
    ENTRAID --> PACKAGES["📁 access-packages/"]
    ENTRAID --> PIM["📁 pim-configuration/"]

    %% Attack Simulation
    ATTACK --> S1["📁 scenario-01\nmfa-fatigue"]
    ATTACK --> S2["📁 scenario-02\ndormant-account\nreactivation"]
    ATTACK --> S3["📁 scenario-03\nbulk-data\nexfiltration"]

    classDef folder fill:#0078d4,stroke:#005a9e,color:#fff
    classDef file fill:#505050,stroke:#383838,color:#fff
    classDef adr fill:#8764b8,stroke:#6b4f9e,color:#fff
    classDef sentinel fill:#c43e1c,stroke:#a33519,color:#fff
    classDef attack fill:#107c10,stroke:#0a5c0a,color:#fff

    class ROOT,DOCS,TERRAFORM,SENTINEL,ENTRAID,SCRIPTS,ATTACK,ADR folder
    class README,ARCH,THREAT,LIFECYCLE,SOD,FRAMEWORK file
    class ADR1,ADR2,ADR3,ADR4 adr
    class RULES,WORKBOOKS,PLAYBOOKS,CA,ROLES,PACKAGES,PIM sentinel
    class S1,S2,S3 attack
```
---

## Deployment Prerequisites

- Azure subscription (free tier sufficient for lab)
- Microsoft 365 tenant with Entra ID P2
- Terraform >= 1.5
- Azure CLI
- PowerShell 7 with Microsoft.Graph module

See [`terraform/README.md`](terraform/README.md) for full deployment instructions.

---

## Framework Mappings

Full control mapping in [`docs/adr/framework-mapping.md`](docs/adr/framework-mapping.md)

| Framework | Coverage |
|---|---|
| ACSC Essential Eight | MFA (ML2), Restrict Admin (ML2), Application Control |
| VPDSF / VPDSS | ICT Security, Information Security, Personnel Security |
| NIST 800-207 | Zero Trust Architecture principles |
| MITRE ATT&CK | T1078, T1530, T1136, T1098, T1110 |
| ISO 27001 | A.9 Access Control, A.12 Operations Security |

---

## Disclaimer

This is a lab environment using fictitious organisational data. No real personal or financial data is used. All user accounts, organisational structures, and scenarios are simulated for educational and portfolio purposes.

---

*Author: Jonar | GitHub: [jonarm](https://github.com/jonarm)*

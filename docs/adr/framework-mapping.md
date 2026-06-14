# Security Control Framework Mapping

*Author: Jonar | Repository: [jonarm](https://github.com/jonarm)*  
*Frameworks: ACSC Essential Eight | VPDSF VPDSS | NIST 800-207 | NIST CSF | MITRE ATT&CK | ISO 27001*

---

## Purpose

This document maps every security control implemented in this reference 
architecture to the relevant compliance frameworks and standards. It is 
designed to demonstrate how a single technical implementation satisfies 
multiple regulatory and framework obligations simultaneously — a common 
requirement in Australian financial services organisations subject to 
APRA oversight and Victorian government procurement standards.

---

## Framework Summary

| Framework | Relevance to This Architecture |
|---|---|
| **ACSC Essential Eight** | Baseline cyber controls mandated across Australian government and increasingly expected in financial services |
| **VPDSF / VPDSS** | Victorian Protective Data Security Framework — applies to Victorian public sector and recommended for local government |
| **NIST SP 800-207** | Zero Trust Architecture — the conceptual model underpinning this entire design |
| **NIST CSF 2.0** | Cybersecurity Framework — maps to Identify, Protect, Detect, Respond, Recover functions |
| **MITRE ATT&CK** | Threat-based mapping of detection rules to adversary techniques |
| **ISO 27001:2022** | International information security management standard |
| **APRA CPS 234** | APRA prudential standard for information security in financial services |

---

## ACSC Essential Eight Mapping

### Maturity Level Achieved: Level 2 (Target), Level 1 (Minimum Baseline)

| Essential Eight Strategy | Control Implemented | Implementation Detail | ML Achieved |
|---|---|---|---|
| **Multi-Factor Authentication** | Entra ID CA Policy CA001 | MFA required for all users accessing Dynamics 365 and M365 admin portals | ML2 |
| **MFA for privileged users** | CA Policy CA005 + PIM | Phishing-resistant MFA (FIDO2/passkey) required for ERP admin role activation | ML2 |
| **Restrict administrative privileges** | PIM JIT activation | No standing admin access — all privileged roles time-limited with approval | ML2 |
| **Patch applications** | Microsoft SaaS responsibility | D365 is Microsoft-hosted SaaS — patching is Microsoft's responsibility; verified via Defender for Cloud | ML2 |
| **Application control** | Conditional Access + Intune | Only Intune-compliant managed devices permitted to access ERP modules | ML1 |
| **Restrict Microsoft Office macros** | M365 Defender policy | Macro execution blocked for files from internet; signed macros only | ML1 |
| **User application hardening** | Intune device compliance | Browser hardening and attack surface reduction rules via Intune | ML1 |
| **Regular backups** | Microsoft SaaS responsibility | D365 point-in-time restore managed by Microsoft; verified via service health | ML1 |

**Gap noted:** Achieving Essential Eight ML3 across all strategies would 
require phishing-resistant MFA enforced for all users (not just admins), 
and privileged access workstations (PAWs) for all admin activity. 
These are documented as future state recommendations.

---

## VPDSF / VPDSS Mapping

The Victorian Protective Data Security Standards define four security 
domains. The table below maps architecture controls to each domain.

### Domain 1 — Information Security

| VPDSS Requirement | Control Implemented | Detail |
|---|---|---|
| Classify and protect information assets | Dynamics 365 data classification | Financial data classified as Sensitive; DLP policies applied |
| Control access to information | Entra ID RBAC + app roles | Role-based access scoped to job function; SoD enforced |
| Monitor access to sensitive information | Microsoft Sentinel | All D365 access logged; anomaly detection active |
| Manage information security incidents | Sentinel + SOAR playbooks | Automated detection and response for 5 threat scenarios |
| Third-party information security | Vendor access via guest accounts | External access scoped and time-limited via Entitlement Management |

### Domain 2 — ICT Security

| VPDSS Requirement | Control Implemented | Detail |
|---|---|---|
| Secure system configuration | Terraform IaC | All configuration deployed as code; no manual portal changes in production |
| Control privileged access | PIM JIT | Zero standing privilege for ERP admin and Global Admin roles |
| Authenticate users | Entra ID + MFA | MFA enforced via Conditional Access for all users |
| Monitor ICT systems | Microsoft Sentinel | SIEM with 8 custom analytics rules and workbook dashboard |
| Manage vulnerabilities | Defender for Cloud | Continuous security posture assessment and recommendations |
| Protect data in transit | TLS 1.2+ enforced | Conditional Access blocks legacy auth protocols |

### Domain 3 — Personnel Security

| VPDSS Requirement | Control Implemented | Detail |
|---|---|---|
| Manage access for joiners | SCIM provisioning + access packages | Automated provisioning triggered by HR system; manager approval required |
| Manage access for movers | Access review + package reassignment | Role change triggers access review; old permissions removed before new granted |
| Manage access for leavers | Automated offboarding playbook | HR termination event triggers account disable and role removal within 24 hours |
| Manage privileged user access | PIM + quarterly access reviews | All privileged roles reviewed monthly by CISO and CTO |

### Domain 4 — Physical Security

| VPDSS Requirement | Control Implemented | Detail |
|---|---|---|
| Control physical access to ICT | Out of scope (SaaS) | D365 is Microsoft-hosted; physical security is Microsoft's responsibility |
| Manage devices | Intune device compliance | Managed device required for ERP access via Conditional Access |
| Protect against environmental threats | Out of scope (SaaS) | Microsoft Azure datacentre controls apply |

---

## NIST SP 800-207 Zero Trust Mapping

### Zero Trust Principles Applied

| ZT Principle | Implementation | Architecture Component |
|---|---|---|
| **Verify explicitly** | Every access request authenticated and authorised based on all available signals | Entra ID Conditional Access evaluating user, device, location, and risk |
| **Use least privilege access** | Access limited to minimum required; JIT for elevated roles | PIM + Entitlement Management + SoD enforcement |
| **Assume breach** | Monitor all traffic, detect anomalies, automate response | Sentinel SIEM + Defender for Cloud Apps + SOAR playbooks |
| **Micro-segmentation** | ERP access isolated from general M365 access via app-specific CA policies | CA Policy CA003 and CA005 scoped to D365 app only |
| **Identity as perimeter** | No network-based trust; identity is the sole access control plane | Entra ID as sole IdP; no VPN-based ERP access |

### NIST 800-207 Logical Components

| ZTA Component | Implementation |
|---|---|
| Policy Engine (PE) | Entra ID Conditional Access + Identity Protection |
| Policy Administrator (PA) | Entra ID + PIM approval workflows |
| Policy Enforcement Point (PEP) | Conditional Access + Defender for Cloud Apps |
| Data Sources | Entra ID logs + Defender signals + Sentinel analytics |

---

## NIST CSF 2.0 Mapping

| CSF Function | CSF Category | Control Implemented |
|---|---|---|
| **GOVERN** | Organisational context | Architecture Decision Records; SoD policy; threat model |
| **GOVERN** | Risk management strategy | Risk register in threat model; framework mapping |
| **IDENTIFY** | Asset management | Entra ID app registration; role inventory; SoD matrix |
| **IDENTIFY** | Risk assessment | STRIDE threat model; MITRE ATT&CK mapping |
| **PROTECT** | Identity management | Entra ID P2; MFA; PIM; SCIM provisioning |
| **PROTECT** | Access control | Conditional Access (6 policies); RBAC; SoD enforcement |
| **PROTECT** | Data security | MCAS session controls; DLP; classification |
| **PROTECT** | Platform security | Terraform IaC; Defender for Cloud posture management |
| **DETECT** | Continuous monitoring | Sentinel SIEM; 8 custom KQL analytics rules |
| **DETECT** | Adverse event analysis | Sentinel workbook; Defender XDR correlation |
| **RESPOND** | Incident management | SOAR playbooks; automated session revocation |
| **RESPOND** | Incident analysis | Sentinel investigation graph; playbook audit trail |
| **RECOVER** | Incident recovery | D365 point-in-time restore; documented recovery procedures |

---

## MITRE ATT&CK Coverage Map

### Tactics and Techniques Detected

| Tactic | Technique ID | Technique Name | Sentinel Rule |
|---|---|---|---|
| **Initial Access** | T1078 | Valid Accounts | `erp-dormant-account-activation.json` |
| **Initial Access** | T1110.004 | Credential Stuffing | `erp-credential-stuffing.json` |
| **Credential Access** | T1621 | MFA Request Generation | `mfa-fatigue-detection.json` |
| **Credential Access** | T1528 | Steal Application Access Token | `erp-service-account-interactive.json` |
| **Collection** | T1530 | Data from Cloud Storage | `erp-bulk-data-export.json` |
| **Persistence** | T1098 | Account Manipulation | `privileged-role-assignment.json` |
| **Persistence** | T1136 | Create Account | Entra ID audit logs + Sentinel |
| **Lateral Movement** | T1550 | Use Alternate Authentication Material | `impossible-travel.json` |
| **Privilege Escalation** | T1078.004 | Cloud Accounts | `erp-admin-outside-hours.json` |

### Detection Coverage by Kill Chain Stage
Reconnaissance    →  Not in scope (identity-focused architecture)

Initial Access    →  ████████████████  COVERED (T1078, T1110.004)

Execution         →  ████░░░░░░░░░░░░  PARTIAL

Persistence       →  ████████████████  COVERED (T1098, T1136)

Privilege Esc.    →  ████████████████  COVERED (T1078.004)

Defense Evasion   →  ████░░░░░░░░░░░░  PARTIAL

Credential Access →  ████████████████  COVERED (T1621, T1528)

Discovery         →  ████░░░░░░░░░░░░  PARTIAL

Lateral Movement  →  ████████░░░░░░░░  COVERED (T1550)

Collection        →  ████████████████  COVERED (T1530)

Exfiltration      →  ████████░░░░░░░░  COVERED via MCAS

Impact            →  ████░░░░░░░░░░░░  PARTIAL

**Coverage gaps documented as future state:**
- Defence evasion techniques requiring EDR integration
- Discovery techniques requiring network traffic analysis
- Full exfiltration coverage requiring DLP integration beyond MCAS

---

## ISO 27001:2022 Mapping

| ISO 27001 Control | Control Name | Implementation |
|---|---|---|
| **A.5.15** | Access control | Entra ID RBAC; app roles; SoD matrix |
| **A.5.16** | Identity management | Entra ID lifecycle; SCIM; access packages |
| **A.5.17** | Authentication information | MFA enforcement; PIM; password policies |
| **A.5.18** | Access rights | Entitlement Management; quarterly reviews |
| **A.8.2** | Privileged access rights | PIM JIT; no standing admin; monthly review |
| **A.8.5** | Secure authentication | Conditional Access; phishing-resistant MFA |
| **A.8.15** | Logging | Entra ID audit logs; Sentinel ingestion |
| **A.8.16** | Monitoring activities | Sentinel analytics rules; workbook |
| **A.8.25** | Secure development lifecycle | Terraform IaC; ADRs; peer review |
| **A.8.28** | Secure coding | IaC scanning; no secrets in code |

---

## APRA CPS 234 Mapping

| CPS 234 Requirement | Implementation |
|---|---|
| **Para 15** — Information security capability | Sentinel SIEM; Defender XDR; SOAR response capability |
| **Para 17** — Classify information assets | D365 data classification; sensitivity labels |
| **Para 19** — Implement controls | All controls in this architecture; tested via attack simulation |
| **Para 21** — Control assurance | Access reviews; Terraform state as evidence; Sentinel audit trail |
| **Para 23** — Internal audit | Risk Auditor role (R08); read-only access; quarterly review |
| **Para 25** — Notify APRA of incidents | Sentinel incident → playbook → notification workflow |
| **Para 36** — Third-party providers | Vendor access via guest accounts; MCAS monitoring |

---

## Control Heatmap — Coverage by Framework

| Control | Essential Eight | VPDSF | NIST ZTA | NIST CSF | ISO 27001 | APRA CPS 234 |
|---|---|---|---|---|---|---|
| MFA (CA001) | ✅ ML2 | ✅ ICT | ✅ | ✅ Protect | ✅ A.8.5 | ✅ Para 19 |
| Block Legacy Auth (CA002) | ✅ ML1 | ✅ ICT | ✅ | ✅ Protect | ✅ A.8.5 | ✅ Para 19 |
| Compliant Device (CA003) | ✅ ML1 | ✅ ICT | ✅ | ✅ Protect | ✅ A.8.5 | ✅ Para 19 |
| Risk-based CA (CA004) | ✅ ML2 | ✅ ICT | ✅ | ✅ Protect | ✅ A.8.5 | ✅ Para 19 |
| PIM JIT (R09/R10) | ✅ ML2 | ✅ ICT | ✅ | ✅ Protect | ✅ A.8.2 | ✅ Para 17 |
| SCIM Lifecycle | — | ✅ Personnel | ✅ | ✅ Protect | ✅ A.5.16 | ✅ Para 19 |
| Sentinel SIEM | — | ✅ ICT | ✅ | ✅ Detect | ✅ A.8.16 | ✅ Para 15 |
| SOAR Playbooks | — | ✅ ICT | ✅ | ✅ Respond | ✅ A.8.16 | ✅ Para 25 |
| MCAS Session Control | ✅ ML1 | ✅ Info | ✅ | ✅ Protect | ✅ A.5.15 | ✅ Para 36 |
| SoD Enforcement | — | ✅ Personnel | — | ✅ Govern | ✅ A.5.15 | ✅ Para 19 |
| Access Reviews | — | ✅ Personnel | ✅ | ✅ Identify | ✅ A.5.18 | ✅ Para 21 |
| Terraform IaC | — | ✅ ICT | — | ✅ Govern | ✅ A.8.25 | — |

---

## Future State Recommendations

The following controls would elevate this architecture to Essential 
Eight ML3 and broaden MITRE ATT&CK coverage:

| Recommendation | Framework Benefit | Effort |
|---|---|---|
| Phishing-resistant MFA (FIDO2) for all users | Essential Eight ML3 MFA | Medium |
| Privileged Access Workstations (PAWs) for admins | Essential Eight ML3 Restrict Admin | High |
| Microsoft Purview DLP integration | VPDSF Information Security | Medium |
| Defender for Endpoint full deployment | MITRE ATT&CK Defence Evasion coverage | Medium |
| Continuous access evaluation (CAE) | NIST ZTA real-time policy enforcement | Low |
| Network segmentation for ERP API layer | NIST 800-207 micro-segmentation | High |

---

*Last updated: June 2026 | Author: Jonar*
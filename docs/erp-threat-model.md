# ERP Threat Model — Dynamics 365 Financial Services

*Author: Jonar | Repository: [jonarm](https://github.com/jonarm)*  
*Framework: STRIDE | Methodology: MITRE ATT&CK for Enterprise*

---

## Purpose

This document defines the threat model for a Microsoft Dynamics 365 Finance 
and Operations deployment in a financial services organisation. It identifies 
threat actors, attack surfaces, and specific threat scenarios used to drive 
the security control design in this reference architecture.

---

## System Context

### What We Are Protecting

Contoso Financial Services operates Dynamics 365 Finance and Operations (F&O) 
as its core ERP, managing:

- General ledger and financial reporting
- Accounts payable and receivable
- Supplier payment processing
- Procurement and purchase order approval
- Payroll data integration
- Regulatory financial reporting (APRA, ASIC)

### Why This Is High Value to Attackers

Financial ERP systems are among the highest-value targets in any organisation 
because they sit at the intersection of:

- **Financial data** — payment records, bank account details, supplier invoices
- **Privileged access** — system admins can modify chart of accounts, 
  create vendor records, and approve payments
- **Regulatory data** — APRA and ASIC reportable information
- **Business process control** — an attacker with ERP access can redirect 
  payments, create fraudulent vendors, or manipulate financial records

---

## Threat Actors

| Actor | Motivation | Capability | Likelihood |
|---|---|---|---|
| **Malicious insider** | Financial gain, grievance | High — legitimate access | High |
| **External attacker (credential theft)** | Financial fraud, ransomware | Medium | High |
| **Supply chain / third-party** | Pivot to ERP via vendor access | Medium | Medium |
| **Nation-state / APT** | Financial sector espionage | High | Low |
| **Opportunistic attacker** | Credential stuffing, phishing | Low-Medium | High |

---

## Attack Surface Analysis

### 1. Identity and Authentication Layer
The primary attack surface. Dynamics 365 F&O authenticates exclusively 
through Entra ID — compromising an identity means compromising ERP access.

**Key risks:**
- Phishing and adversary-in-the-middle (AiTM) attacks bypassing MFA
- MFA fatigue attacks against prompt-based MFA
- Legacy authentication protocols bypassing Conditional Access
- Service account credential exposure
- Stolen session tokens (post-authentication token theft)

### 2. Privileged Administration Layer
ERP System Admin roles in Dynamics 365 have unrestricted access to all 
modules, configuration, and data. Standing privileged access dramatically 
increases blast radius of any compromise.

**Key risks:**
- Standing admin accounts targeted via credential attacks
- Privilege escalation from standard ERP user to admin
- Unauthorised role assignment (admin creating admin)
- Breakglass account misuse

### 3. Data Access and Export Layer
Dynamics 365 F&O provides native data export capabilities (Excel export, 
Data Management Framework, OData API) that can be abused for bulk 
exfiltration.

**Key risks:**
- Bulk export of supplier payment data by malicious insider
- API-based data extraction using compromised service principal
- Unauthorised access to financial reporting modules
- Data exfiltration via unmanaged personal devices

### 4. Integration and API Layer
Dynamics 365 integrates with Power Platform, Azure Data Lake, and third-party 
systems via service principals and API connections.

**Key risks:**
- Compromised service principal with overprivileged ERP API access
- Malicious Power Automate flow created by compromised user
- Insecure third-party integration exposing ERP data
- OAuth token abuse via misconfigured app registration

### 5. Joiner / Mover / Leaver Process
Manual or delayed identity lifecycle processes create windows of 
unauthorised access.

**Key risks:**
- Former employee retaining active ERP access post-termination
- Role accumulation during internal transfers (mover scenario)
- Delayed deprovisioning creating dormant privileged accounts
- Shared credentials for ERP service accounts

---

## STRIDE Threat Analysis

| Threat Category | Example | Affected Component | Control |
|---|---|---|---|
| **Spoofing** | Attacker uses stolen credentials to impersonate Finance Manager | Entra ID authentication | MFA + Identity Protection |
| **Tampering** | Insider modifies supplier bank account details in D365 | D365 vendor master data | Audit logging + SoD |
| **Repudiation** | User denies approving fraudulent purchase order | D365 procurement module | Sentinel audit trail |
| **Information Disclosure** | Bulk export of payment records to personal device | D365 data export | MCAS session controls |
| **Denial of Service** | Ransomware encrypts Entra ID sync preventing ERP access | Entra ID Connect | Defender XDR + backup |
| **Elevation of Privilege** | Standard user assigns themselves ERP Admin role | Entra ID app roles | PIM + role assignment alerts |

---

## Threat Scenarios (Detailed)

### TS-01 — MFA Fatigue Attack
**Actor:** External attacker with valid credentials from phishing  
**Technique:** MITRE ATT&CK T1621 — Multi-Factor Authentication Request Generation  
**Narrative:**
An attacker obtains a Finance Manager's credentials via a phishing email. 
They initiate repeated MFA push notification requests until the user 
approves one out of fatigue or confusion. The attacker gains a valid 
session token and accesses Dynamics 365 finance modules.

**Detection:** Sentinel rule `mfa-fatigue-detection.json` — fires on 
10+ MFA requests within 10 minutes for a single user  
**Response:** SOAR playbook revokes session, forces password reset, 
notifies security team  
**Preventive Control:** Number matching MFA, Conditional Access 
sign-in frequency policy

---

### TS-02 — Bulk Financial Data Exfiltration
**Actor:** Malicious insider (Finance User, pre-resignation)  
**Technique:** MITRE ATT&CK T1530 — Data from Cloud Storage  
**Narrative:**
A Finance user with legitimate access to the accounts payable module 
begins exporting large volumes of supplier payment records to Excel 
over several days. The data volume significantly exceeds their normal 
baseline behaviour. The user intends to take the data to a competitor.

**Detection:** Defender for Cloud Apps activity policy fires on bulk 
export exceeding threshold; Sentinel rule `erp-bulk-data-export.json` 
correlates with after-hours login  
**Response:** SOAR playbook quarantines user session, alerts security 
team with export details  
**Preventive Control:** MCAS session controls block download on 
unmanaged devices; DLP policy on ERP data classification

---

### TS-03 — Dormant Privileged Account Reactivation
**Actor:** External attacker using credentials from prior breach  
**Technique:** MITRE ATT&CK T1078 — Valid Accounts  
**Narrative:**
A former ERP System Admin left the organisation six months ago. Due 
to a gap in the offboarding process, their Entra ID account was 
disabled but their Dynamics 365 app role assignment was not removed. 
An attacker obtains their credentials from a dark web dump and 
re-enables the account via a misconfigured self-service password reset 
policy. They activate the dormant ERP admin role and access financial 
configuration settings.

**Detection:** Sentinel rule `erp-dormant-account-activation.json` 
fires on accounts inactive for 30+ days suddenly accessing ERP  
**Response:** SOAR playbook immediately disables account and pages 
on-call security  
**Preventive Control:** Automated leaver workflow removes all app role 
assignments within 24 hours of HR termination event; SSPR scoped 
to active employees only

---

### TS-04 — Service Principal Abuse
**Actor:** External attacker via compromised developer workstation  
**Technique:** MITRE ATT&CK T1528 — Steal Application Access Token  
**Narrative:**
A developer's workstation is compromised via a malicious npm package. 
The attacker extracts a client secret for a Dynamics 365 API service 
principal stored in a local `.env` file. Using the service principal, 
they query the OData API directly, bypassing all user-facing Conditional 
Access policies, and extract financial records programmatically.

**Detection:** Sentinel rule `erp-service-account-interactive.json` 
fires on service principal used outside expected API patterns; 
anomalous query volume alert  
**Response:** Service principal credential rotated automatically via 
playbook; access reviewed  
**Preventive Control:** Client secrets stored in Azure Key Vault only; 
service principal access scoped to minimum required API permissions; 
certificate-based auth preferred over secrets

---

### TS-05 — Credential Stuffing Against SSO
**Actor:** Opportunistic external attacker  
**Technique:** MITRE ATT&CK T1110.004 — Credential Stuffing  
**Narrative:**
An attacker purchases a leaked credential list containing corporate 
email addresses and attempts automated logins against the Dynamics 365 
SSO endpoint. After multiple failures, one credential pair succeeds for 
a Procurement Officer account. Conditional Access detects the elevated 
sign-in risk and demands step-up MFA the attacker cannot satisfy.

**Detection:** Sentinel rule `erp-credential-stuffing.json` fires on 
10+ failed logins followed by success from same IP  
**Response:** Account flagged as high risk in Identity Protection; 
sign-in blocked pending password reset  
**Preventive Control:** Entra ID Identity Protection user risk policy; 
smart lockout; Conditional Access CA004 requiring MFA on medium+ risk

---

## Risk Register

| ID | Threat Scenario | Likelihood | Impact | Inherent Risk | Residual Risk (with controls) |
|---|---|---|---|---|---|
| TS-01 | MFA Fatigue | High | High | Critical | Medium |
| TS-02 | Bulk Exfiltration | Medium | High | High | Low |
| TS-03 | Dormant Account | Medium | Critical | High | Low |
| TS-04 | Service Principal Abuse | Medium | High | High | Medium |
| TS-05 | Credential Stuffing | High | Medium | High | Low |

---

## MITRE ATT&CK Coverage

| Technique ID | Technique Name | Detected By |
|---|---|---|
| T1621 | MFA Request Generation | `mfa-fatigue-detection.json` |
| T1530 | Data from Cloud Storage | `erp-bulk-data-export.json` |
| T1078 | Valid Accounts | `erp-dormant-account-activation.json` |
| T1528 | Steal Application Access Token | `erp-service-account-interactive.json` |
| T1110.004 | Credential Stuffing | `erp-credential-stuffing.json` |
| T1098 | Account Manipulation | `privileged-role-assignment.json` |
| T1136 | Create Account | Sentinel + Entra ID audit logs |

---

## Assumptions and Exclusions

**Assumptions:**
- Dynamics 365 F&O is Microsoft-hosted SaaS (not on-premises or private cloud)
- Entra ID is the sole identity provider — no on-premises AD federation in scope
- All users are issued managed devices (Intune-enrolled) as a baseline
- HR system integration triggers identity lifecycle events

**Exclusions:**
- Physical security controls
- Dynamics 365 application-layer security (module permissions within D365)
- Network perimeter controls (out of scope for this identity-focused architecture)
- Disaster recovery and backup procedures

---

*Last updated: June 2026 | Author: Jonar*
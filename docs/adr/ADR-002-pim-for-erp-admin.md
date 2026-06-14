# ADR-002: Privileged Identity Management Configuration for ERP Admin Roles

*Author: Jonar | Repository: [jonarm](https://github.com/jonarm)*  
*Status: Accepted*  
*Date: June 2026*  
*Deciders: Security Architecture, Identity Team, CISO*

---

## Context

Dynamics 365 Finance and Operations System Admin and Global Admin roles 
represent the highest privilege tier in the Contoso Financial Services 
environment. These roles have unrestricted access to:

- All Dynamics 365 modules including financial configuration
- Chart of accounts and general ledger settings
- User provisioning and role assignment within D365
- Integration configuration and API credentials
- Audit log access and potential log suppression

In the original environment design, these roles were assigned as standing 
permissions — administrators held the roles permanently and could exercise 
them at any time without additional authentication or approval. This 
represents a critical security gap:

- A compromised admin account has immediate, unrestricted ERP access
- There is no approval gate to catch insider misuse of admin privileges
- Privileged sessions are indistinguishable from normal admin activity
- The blast radius of any admin account compromise is maximised

A decision is required on how to implement Privileged Identity Management 
(PIM) for these roles — specifically the activation workflow, approval 
requirements, session duration, and monitoring approach.

---

## Decision Drivers

1. **Eliminate standing privileged access** — no admin should hold 
   permanent ERP admin rights
2. **Enforce approval for sensitive role activation** — a second person 
   must authorise admin access
3. **Minimise activation window** — privileged access should be 
   time-limited to the minimum required
4. **Maintain operational continuity** — PIM must not block legitimate 
   emergency access scenarios
5. **Create an auditable trail** — every activation must be logged with 
   business justification
6. **Align to Essential Eight ML2** — restrict administrative privileges 
   is a core Essential Eight strategy

---

## Options Considered

### Option 1 — Standing Privileged Access (Status Quo)

Retain permanent role assignments for ERP System Admin and Global Admin. 
Rely on strong authentication (MFA) and monitoring as compensating controls.

**Strengths:**
- No operational friction — admins can act immediately
- No risk of being locked out during an incident

**Weaknesses:**
- Permanent privileged access maximises breach impact
- Does not satisfy Essential Eight ML2 restrict administrative privileges
- No approval gate — insider threat risk is unrestricted
- Fails APRA CPS 234 Para 17 proportional control requirements
- Any credential compromise gives immediate full ERP access

**Decision: Rejected** — the security risk is disproportionate and 
this approach fails multiple framework requirements.

---

### Option 2 — PIM with Self-Approval

Implement PIM for all privileged roles but allow the requesting admin 
to self-approve their own activation. Requires business justification 
text entry and MFA re-authentication.

**Strengths:**
- Eliminates standing access
- Creates audit trail of every activation with justification
- Adds MFA re-authentication step before privilege exercise
- Low operational friction — no dependency on a second person

**Weaknesses:**
- Self-approval provides no protection against insider threat
- A compromised account can self-approve its own privilege escalation
- Does not satisfy the intent of segregation of duties for admin access
- Audit trail exists but approval is not a meaningful control

**Decision: Rejected for production privileged roles** — acceptable 
only as a fallback for breakglass scenarios.

---

### Option 3 — PIM with Mandatory Peer Approval

Implement PIM for all privileged roles with mandatory approval from 
a designated approver (CISO or CTO) before activation is granted. 
Activation window time-limited. Full justification required.

**Strengths:**
- Eliminates standing access entirely
- Two-person rule for all privileged access — strong insider threat control
- Time-limited activation minimises exposure window
- Full audit trail — justification, approver identity, activation time
- Satisfies Essential Eight ML2 and APRA CPS 234 requirements
- Aligns to NIST 800-207 least privilege principle

**Weaknesses:**
- Operational dependency on approver availability
- Risk of access delay during out-of-hours incidents
- Requires approver training and awareness of their responsibilities

**Decision: Accepted for all production privileged roles**

---

### Option 4 — PIM with Approval + Dedicated Breakglass Accounts

Implement Option 3 as the standard path, with two dedicated breakglass 
accounts held outside PIM for emergency use when the approval chain 
is unavailable. Breakglass accounts are physically secured, monitored 
in real-time, and subject to post-use review.

**Decision: Accepted as the complete solution** — Option 3 for 
standard operations, breakglass accounts for genuine emergencies.

---

## Decision

**Selected: Option 4 — PIM with Mandatory Peer Approval + Breakglass Accounts**

---

## PIM Configuration Specification

### Role: ERP System Admin (D365.SystemAdmin)

| Parameter | Value | Rationale |
|---|---|---|
| Assignment type | Eligible only — no permanent active | Eliminates standing access |
| Maximum activation duration | 4 hours | Sufficient for planned maintenance windows |
| Activation requires MFA | Yes — phishing-resistant FIDO2 | Prevents token theft activation |
| Activation requires justification | Yes — mandatory text field | Audit trail and accountability |
| Activation requires approval | Yes — single approver | Two-person rule |
| Approver(s) | CISO (primary), CTO (secondary) | Senior accountability |
| Approver notification | Email + Teams message | Immediate awareness |
| Activation notification | Email to security team | Real-time awareness |
| On activation alert | Sentinel alert fires immediately | Detection layer |
| Assignment expiry | 12 months — then re-eligible assessment | Periodic review |

---

### Role: Global Admin (EntraID.GlobalAdmin)

| Parameter | Value | Rationale |
|---|---|---|
| Assignment type | Eligible only — no permanent active | Eliminates standing access |
| Maximum activation duration | 2 hours | Shorter window — highest risk role |
| Activation requires MFA | Yes — phishing-resistant FIDO2 | Mandatory for highest privilege |
| Activation requires justification | Yes — mandatory text field | Full audit trail |
| Activation requires approval | Yes — dual approval | Two approvers for highest risk |
| Approver(s) | CISO + CTO (both must approve) | Dual control for global admin |
| Approver notification | Email + Teams + SMS | Multi-channel for critical role |
| Activation notification | Email to security team + board secretary | Executive awareness |
| On activation alert | Sentinel critical alert | Immediate SOC awareness |
| Assignment expiry | 12 months — then re-eligible assessment | Periodic review |

---

### Role: Finance Manager (D365.Finance.Manager)

| Parameter | Value | Rationale |
|---|---|---|
| Assignment type | Active permanent — not PIM | Operational role, not admin |
| MFA enforced | Yes — via Conditional Access CA002 | Standard MFA for all users |
| Access review | Quarterly via Entra ID Access Reviews | Periodic revalidation |

*Note: Finance Manager is an elevated business role but not a privileged 
admin role — PIM is not appropriate. Conditional Access and access 
reviews provide sufficient control.*

---

## Breakglass Account Configuration

Two breakglass accounts are maintained outside the standard PIM workflow 
for genuine emergency scenarios where the approval chain is unavailable 
(e.g. simultaneous unavailability of CISO and CTO during a major incident).

| Parameter | Configuration |
|---|---|
| Account naming | `breakglass-01@contosofinancial.onmicrosoft.com` |
| Account type | Cloud-only — not synced from on-premises AD |
| MFA method | FIDO2 hardware key — stored in physical safe |
| Password | Complex, stored in sealed envelope in physical safe |
| Excluded from | All Conditional Access policies except MFA |
| Monitoring | Any sign-in triggers immediate Sentinel critical alert |
| Review frequency | Quarterly — verify credentials still valid, access log reviewed |
| Post-use requirement | Mandatory incident report within 24 hours of any use |

**Breakglass is not a convenience mechanism.** Use of breakglass 
accounts triggers an automatic security review. All actions taken 
during a breakglass session are logged and reviewed within 24 hours.

---

## Operational Runbook

### Standard Admin Access Request
1. Admin navigates to MyAccess portal (myaccess.microsoft.com)
2. Selects eligible role (ERP System Admin or Global Admin)
3. Enters business justification (minimum 50 characters)
4. Completes FIDO2 MFA re-authentication
5. Approver receives notification via email and Teams
6. Approver reviews justification and approves or denies
7. On approval: role activates for specified duration
8. Sentinel alert fires — security team notified
9. Admin performs required tasks within activation window
10. Role deactivates automatically at window expiry
11. Activation logged to Sentinel for audit trail

### Out-of-Hours Approval

Primary approver (CISO) is on-call for PIM approvals.  
Secondary approver (CTO) covers when CISO is unavailable.  
If both unavailable AND situation is a genuine emergency:  
→ Breakglass account may be used per breakglass procedure above.

### PIM Activation Denied — Escalation Path
Approval denied → Admin contacts approver directly (phone)

→ If legitimate: approver re-approves via MyAccess portal

→ If approver unreachable: escalate to secondary approver

→ If both unreachable and genuine emergency: breakglass procedure

---

## Monitoring and Alerting

All PIM activations generate Sentinel analytics rule alerts:

| Event | Sentinel Rule | Severity | Response |
|---|---|---|---|
| ERP Admin role activated | `erp-admin-outside-hours.json` (if outside hours) | High | Security team review |
| Global Admin role activated | `privileged-role-assignment.json` | Critical | Immediate SOC response |
| Breakglass account sign-in | Custom alert — any sign-in | Critical | Immediate incident declaration |
| PIM role assigned to new user | `privileged-role-assignment.json` | High | Security team review |
| Failed PIM activation attempt | Identity Protection alert | Medium | Review for brute force |

---

## Consequences

### Positive
- Zero standing privileged access across all admin roles
- Two-person rule for all ERP and tenant admin activation
- Complete audit trail — every activation logged with identity, 
  justification, approver, and duration
- Satisfies Essential Eight ML2 restrict administrative privileges
- Satisfies APRA CPS 234 Para 17 proportional controls
- Dramatically reduces blast radius of any admin credential compromise
- Breakglass accounts ensure operational resilience without 
  compromising the standard approval model

### Negative
- Operational friction — admins cannot act immediately without approval
- Approver availability dependency — CISO and CTO must be reachable
- Training required — all eligible admins and approvers need PIM 
  workflow training before go-live
- FIDO2 hardware keys must be procured and distributed to all 
  eligible admins

### Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Approver unavailable during incident | Secondary approver defined; breakglass as last resort |
| Admin forgets to deactivate role | Automatic expiry at maximum window — no manual step needed |
| Breakglass credentials compromised | Physical security of safe; quarterly credential verification |
| PIM activation from compromised account | FIDO2 MFA required — credential theft alone insufficient |
| Approver socially engineered into approving | Justification review training; Sentinel alert allows security team cross-check |

---

## Related Decisions
- [ADR-001: SSO Protocol Selection](ADR-001-sso-saml-vs-oidc.md)
- [ADR-003: MCAS Session Controls](ADR-003-mcas-session-controls.md)
- [ADR-004: SCIM vs Manual Provisioning](ADR-004-scim-vs-manual-provisioning.md)

---

## References
- Microsoft Docs: Configure PIM for Azure AD roles
- ACSC Essential Eight: Restrict Administrative Privileges
- APRA CPS 234: Information Security
- NIST SP 800-207: Zero Trust Architecture
- Microsoft: Secure access practices for administrators

---

*Last updated: June 2026 | Author: Jonar*
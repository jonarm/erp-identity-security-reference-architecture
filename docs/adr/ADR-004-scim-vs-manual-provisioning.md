# ADR-004: User Provisioning — SCIM Automated vs Manual Provisioning for Dynamics 365

*Author: Jonar | Repository: [jonarm](https://github.com/jonarm)*  
*Status: Accepted*  
*Date: June 2026*  
*Deciders: Security Architecture, Identity Team, HR Operations, CISO*

---

## Context

Contoso Financial Services requires a reliable, secure, and auditable 
method for provisioning and deprovisioning user access to Dynamics 365 
Finance and Operations. The organisation has 25 staff across Finance, 
Procurement, IT, and Risk & Compliance, with regular joiners, movers, 
and leavers driven by HR system events.

The current state at project initiation is fully manual:

- HR notifies IT via email when a new employee joins
- IT manually creates the Entra ID account and assigns D365 roles
- Role changes during internal transfers are handled ad hoc
- Deprovisioning relies on HR notifying IT at offboarding — 
  a process with documented failures resulting in former employees 
  retaining active D365 access beyond their termination date

This manual process has produced the following documented risk events:

- Two instances in the past 18 months of terminated employees 
  retaining active Dynamics 365 access for more than 30 days 
  post-termination
- One instance of a transferred employee retaining Finance Manager 
  access after moving to a Procurement role — a live SoD violation
- Inconsistent role assignment — same job title receiving different 
  D365 roles depending on which IT staff member processed the request

A decision is required on the target provisioning architecture to 
eliminate these gaps.

---

## Decision Drivers

1. **Eliminate deprovisioning lag** — terminated employees must lose 
   access within a defined SLA, not subject to manual process reliability
2. **Enforce consistent role assignment** — same job title must always 
   receive the same D365 roles regardless of who processes the request
3. **Satisfy SoD constraints at provisioning time** — the provisioning 
   system must enforce SoD rules, not rely on post-provisioning review
4. **Create an auditable provisioning trail** — every access grant and 
   revocation must be logged with the triggering event
5. **Reduce IT operational burden** — provisioning should not require 
   manual IT intervention for standard joiner/mover/leaver events
6. **Align to VPDSF Personnel Security domain** — automated lifecycle 
   management is a VPDSS requirement for regulated entities
7. **Satisfy APRA CPS 234** — access controls must be proportional 
   to risk and subject to regular review

---

## Options Considered

### Option 1 — Retain Manual Provisioning with Process Improvements

Retain the current manual provisioning process but add structured 
controls:

- Standardised request form replacing email notification
- SLA of 24 hours for joiner provisioning, 4 hours for leaver 
  deprovisioning
- Checklist-based process with manager sign-off
- Weekly audit of active accounts against HR system

**Strengths:**
- No technical implementation required
- Familiar to existing IT team
- Low cost

**Weaknesses:**
- Relies entirely on human process adherence — same failure modes 
  as current state
- SLA compliance cannot be technically enforced — depends on IT 
  workload and attention
- Does not scale as organisation grows
- Audit is periodic not continuous — access gaps exist between audits
- Does not satisfy the intent of VPDSF automated lifecycle management
- Documented failures in current state give low confidence in 
  process improvement alone

**Decision: Rejected** — process improvement alone is insufficient 
given documented failure history and regulatory obligations.

---

### Option 2 — Manual Provisioning via Entra ID Access Packages Only

Replace ad hoc role assignment with structured Entra ID Entitlement 
Management access packages. IT still manually assigns packages but 
within a governed framework:

- Predefined access packages per role (Finance Standard, 
  Finance Manager, Procurement Officer etc.)
- Manager self-service request portal — managers request access 
  for their staff
- Approval workflow built into access packages
- Automatic expiry and access reviews

**Strengths:**
- Eliminates ad hoc role assignment — consistent package-based access
- Manager-driven request reduces IT bottleneck for joiners
- Access reviews built in — periodic revalidation automated
- SoD constraints enforceable at package level
- No HR system integration required

**Weaknesses:**
- Deprovisioning still manual — leaver process still depends on 
  manager or HR notifying IT
- No automatic trigger from HR system — the documented deprovisioning 
  failure mode remains
- Mover scenarios still require manual intervention

**Decision: Accepted as a component** — access packages are part 
of the solution but insufficient alone due to the deprovisioning gap.

---

### Option 3 — Full SCIM Automated Provisioning from HR System

Implement SCIM 2.0 (System for Cross-domain Identity Management) 
to automate user lifecycle management from the HR system directly 
into Entra ID and Dynamics 365:

- HR system is the authoritative source of truth for identity
- SCIM connector syncs user create, update, and delete events 
  from HR to Entra ID automatically
- Entra ID provisions and deprovisions D365 access based on 
  HR system attributes (department, job title, employment status)
- Termination event in HR system triggers automatic account 
  disable and role removal within defined SLA
- Role change (mover) triggers automatic access package 
  reassignment based on new job title

**How SCIM works in this architecture:**
HR System (source of truth)

│

│ SCIM 2.0 protocol

▼

Entra ID Provisioning Service

│

├── Create user → Entra ID account created

│                  Access package assigned by job title

│                  D365 roles provisioned via package

│

├── Update user → Department/title change detected

│                  Old access package removed

│                  New access package assigned

│                  SoD check enforced at assignment

│

└── Disable user → Employment status = Terminated

Entra ID account disabled immediately

All D365 roles removed

Active sessions revoked

PIM eligible assignments removed

**Strengths:**
- Eliminates manual deprovisioning — termination is automatic 
  and immediate
- Joiner provisioning triggered by HR system — no IT manual step
- Mover access changes driven by HR role change — no gap period
- Consistent role assignment — job title maps to access package 
  deterministically
- Full audit trail — every provisioning event logged in Entra ID 
  audit logs and Sentinel
- Scales automatically as organisation grows
- Satisfies VPDSF Personnel Security automated lifecycle requirement
- Eliminates the documented deprovisioning failure mode entirely

**Weaknesses:**
- Requires HR system to support SCIM 2.0 export — not all HR 
  systems support this natively
- Initial configuration complexity — attribute mapping between 
  HR system and Entra ID requires careful design
- HR data quality is critical — incorrect job title or department 
  in HR system results in incorrect access
- Requires ongoing maintenance as job titles and departments change

**Decision: Accepted as the primary provisioning mechanism**

---

### Option 4 — SCIM Automated Provisioning + Access Packages + Manual Exception Process

Combine Option 3 (SCIM automation) with Option 2 (access packages) 
as the role assignment layer, plus a documented manual exception 
process for non-standard access requests:

- SCIM handles all standard joiner/mover/leaver events automatically
- Access packages define and enforce what access each job title receives
- SoD constraints enforced at the access package layer
- Manual exception process (with CISO approval) for non-standard 
  access requirements
- All exceptions time-limited and subject to quarterly review

**Decision: Accepted as the complete solution**

---

## Decision

**Selected: Option 4 — SCIM Automated Provisioning + Entra ID 
Access Packages + Manual Exception Process**

---

## SCIM Configuration Specification

### HR System to Entra ID Attribute Mapping

| HR System Attribute | Entra ID Attribute | Usage |
|---|---|---|
| `employee_id` | `employeeId` | Unique identifier |
| `first_name` + `last_name` | `displayName` | Display name |
| `email` | `userPrincipalName` | Primary identity |
| `department` | `department` | Access package selection |
| `job_title` | `jobTitle` | Access package selection |
| `employment_status` | `accountEnabled` | Active/disabled state |
| `manager_email` | `manager` | Approval workflow |
| `start_date` | Custom attribute | Pre-provisioning trigger |
| `termination_date` | Custom attribute | Scheduled deprovisioning |

---

### Job Title to Access Package Mapping

| Job Title (HR System) | Access Package Assigned | D365 Roles Granted |
|---|---|---|
| Finance Analyst | Finance Standard | R01 — Finance User |
| Finance Manager | Finance Management | R02 — Finance Manager |
| Accounts Payable Officer | Accounts Payable | R03 — AP Officer |
| Payment Officer | Payment Processing | R04 — Payment Processor |
| Procurement Officer | Procurement Standard | R05 — Procurement Officer |
| Procurement Manager | Procurement Approval | R06 — Procurement Approver |
| Vendor Manager | Vendor Management | R07 — Vendor Master Maintainer |
| Internal Auditor | Audit Read-Only | R08 — Risk Auditor |
| IT Systems Administrator | ERP Admin (JIT) | R09 — ERP System Admin (eligible) |

*Note: SoD conflicts defined in the SoD matrix are enforced at the 
access package layer — incompatible packages cannot be assigned to 
the same user by the provisioning system.*

---

### Provisioning SLAs

| Event | Trigger | SLA | Technical Enforcement |
|---|---|---|---|
| Joiner — account creation | HR system: new employee record | 24 hours before start date | SCIM pre-provisioning on start_date - 1 |
| Joiner — access assignment | Account created | Immediate | Automatic access package assignment |
| Mover — role change | HR system: job title/department update | 4 hours | SCIM update event triggers package reassignment |
| Leaver — account disable | HR system: employment_status = Terminated | 1 hour | SCIM deprovision event disables account |
| Leaver — role removal | Account disabled | Immediate | Automatic with account disable |
| Leaver — session revocation | Account disabled | Immediate | Entra ID revokes all active tokens |
| Leaver — PIM removal | Account disabled | Immediate | Eligible PIM assignments removed |

---

### Joiner Workflow (Detailed)
Day -5: HR creates employee record in HR system

└── SCIM syncs to Entra ID (account created, disabled)
Day -1: Scheduled enable trigger fires

└── Account enabled in Entra ID

└── Access package assigned based on job title mapping

└── D365 roles provisioned via package

└── Welcome email sent with login instructions

└── Manager notified of provisioning completion

└── Sentinel log: joiner provisioning event
Day 1:  Employee starts — account and access ready

└── Manager completes access verification checklist

---

### Leaver Workflow (Detailed)
HR marks employee as Terminated (employment_status = Terminated)

│

├── SCIM deprovision event fires within 1 hour

│

├── Entra ID account disabled immediately

│    └── All active sessions invalidated (token revocation)

│    └── MFA methods retained for 30 days (audit purposes)

│

├── All access package assignments removed

│    └── D365 roles deprovisioned

│    └── PIM eligible assignments removed

│

├── Sentinel alert: leaver deprovisioning event logged

│

├── Manager notified of deprovisioning completion

│

└── Day +30: Account permanently deleted from Entra ID

└── Audit logs retained per retention policy

---

### Mover Workflow (Detailed)
HR updates employee job title or department

│

├── SCIM update event fires within 4 hours

│

├── Entra ID attributes updated (department, jobTitle)

│

├── Current access package evaluated against new job title

│    └── If package changes required:

│         ├── New access package assigned first

│         └── Old access package removed after confirmation

│              (never remove before grant — prevents access gap)

│

├── SoD check: new package combination validated

│    └── If SoD conflict detected: provisioning blocked

│    └── Security team alerted for manual resolution

│

└── Sentinel alert: mover access change event logged

---

## Exception Process

For non-standard access requirements not covered by the standard 
job title mapping:

1. **Request** — submitted via Entra ID MyAccess portal with 
   business justification
2. **Manager approval** — line manager approves the request
3. **Security review** — security team validates against SoD matrix
4. **CISO approval** — required for any access outside standard mapping
5. **Time-limited grant** — maximum 90 days; must be renewed
6. **Quarterly review** — all exceptions reviewed by CISO quarterly
7. **Exception register** — maintained by Risk & Compliance team

---

## Monitoring and Alerting

All provisioning events are logged to Entra ID audit logs and 
ingested into Microsoft Sentinel:

| Event | Alert | Severity |
|---|---|---|
| Leaver account not disabled within SLA | Sentinel alert | High |
| Manual role assignment outside SCIM | Sentinel alert | High |
| SoD conflict detected at provisioning | Sentinel alert | Critical |
| Dormant account active after 30 days | `erp-dormant-account-activation.json` | High |
| Exception access package approaching expiry | Automated email | Medium |
| SCIM sync failure | Sentinel alert | High |

---

## Consequences

### Positive
- Eliminates documented deprovisioning failure mode — termination 
  is automatic and immediate regardless of IT workload
- Consistent role assignment — job title determines access 
  deterministically, not per-request interpretation
- SoD enforced at provisioning time — conflicts cannot be 
  created by the automated system
- Full audit trail — every provisioning event logged with 
  triggering HR event, timestamp, and resulting access changes
- Reduces IT operational burden for standard lifecycle events
- Satisfies VPDSF Personnel Security domain requirements
- Satisfies APRA CPS 234 Para 19 and Para 21 requirements
- Scales as organisation grows without proportional IT effort increase

### Negative
- HR data quality is now a security dependency — incorrect 
  HR data produces incorrect access
- SCIM connector configuration requires upfront investment 
  and ongoing maintenance
- HR system must support SCIM 2.0 — if not, middleware 
  adapter required
- Mover workflow complexity — attribute changes must be 
  mapped carefully to avoid unintended access changes

### Risks and Mitigations

| Risk | Mitigation |
|---|---|
| HR system does not support SCIM natively | Microsoft Entra ID supports SCIM connectors and custom connectors via Azure Logic Apps as middleware |
| Incorrect HR data causes wrong access assignment | HR data quality review prior to go-live; Sentinel alert on unexpected role assignments |
| SCIM sync failure leaves account active post-termination | Sentinel alert on sync failure; daily reconciliation report comparing HR system against Entra ID |
| Mover workflow removes access before new access granted | New package assigned first in all mover workflows — never remove before grant |
| Exception process circumvented via direct role assignment | Direct role assignment outside SCIM triggers Sentinel alert; reviewed within 24 hours |

---

## Related Decisions
- [ADR-001: SSO Protocol Selection](ADR-001-sso-saml-vs-oidc.md)
- [ADR-002: PIM for ERP Admin Roles](ADR-002-pim-for-erp-admin.md)
- [ADR-003: MCAS Session Controls](ADR-003-mcas-session-controls.md)

---

## References
- Microsoft Docs: How provisioning works in Entra ID
- Microsoft Docs: SCIM synchronisation with Entra ID
- SCIM 2.0 RFC 7644
- VPDSF: Personnel Security Domain
- APRA CPS 234: Information Security
- Microsoft Docs: Entitlement Management access packages

---

*Last updated: June 2026 | Author: Jonar*
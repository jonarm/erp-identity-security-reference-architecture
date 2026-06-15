# Segregation of Duties — Dynamics 365 Financial Services

*Author: Jonar | Repository: [jonarm](https://github.com/jonarm)*  
*Standard: ISO 27001 A.9 | APRA CPS 234 | SOX Equivalent Controls*

---

## Purpose

This document defines the Segregation of Duties (SoD) control framework 
for Dynamics 365 Finance and Operations at Contoso Financial Services. 
SoD controls prevent any single user from having end-to-end control over 
a financial process — a foundational requirement for fraud prevention, 
audit compliance, and regulatory obligations under APRA CPS 234.

SoD violations in ERP systems are among the most common findings in 
financial services audits and represent a direct fraud risk when 
privileged ERP access is combined with financial approval authority.

---

## SoD Principles Applied

### 1. No Single User Controls a Complete Financial Process
A user who can **create** a transaction cannot **approve** the same 
transaction. A user who can **create a vendor** cannot **process a 
payment** to that vendor.

### 2. Least Privilege by Default
ERP roles are scoped to the minimum access required for job function. 
Broader access requires formal request, manager approval, and time-limited 
entitlement via Entra ID Access Packages.

### 3. Privilege Is Not Permanent
All elevated ERP roles (Finance Manager, Procurement Approver, ERP Admin) 
are subject to quarterly access reviews via Entra ID Access Reviews. 
ERP System Admin access is JIT only via PIM — no standing access.

### 4. Technical Controls Enforce SoD — Not Policy Alone
SoD rules are enforced through Entra ID app role constraints and 
Dynamics 365 duty separation — not reliant on users following policy.

---

## ERP Role Definitions

| Role ID | Role Name | Department | Description |
|---|---|---|---|
| R01 | Finance User | Finance | View and enter journal entries, run standard reports |
| R02 | Finance Manager | Finance | Approve journal entries, access financial statements |
| R03 | Accounts Payable Officer | Finance | Create and manage vendor invoices |
| R04 | Payment Processor | Finance | Process and release supplier payments |
| R05 | Procurement Officer | Procurement | Create purchase requisitions and orders |
| R06 | Procurement Approver | Procurement | Approve purchase orders above threshold |
| R07 | Vendor Master Maintainer | Procurement | Create and modify vendor records |
| R08 | Risk Auditor | Risk & Compliance | Read-only access to all modules for audit |
| R09 | ERP System Admin | IT | Full system configuration access — JIT via PIM only |
| R10 | Global Admin | IT | Entra ID tenant admin — JIT via PIM only, emergency only |

---

## SoD Conflict Matrix

The matrix below defines incompatible role combinations. A conflict 
means a single user must never hold both roles simultaneously.

**Legend:**
- 🔴 **CONFLICT** — Technically blocked via Entra ID app role constraints
- ⚠️ **RISK** — Permitted only with documented compensating control and CISO approval
- ✅ **PERMITTED** — No SoD conflict

<table>
  <thead>
    <tr>
      <th></th>
      <th>R01</th>
      <th>R02</th>
      <th>R03</th>
      <th>R04</th>
      <th>R05</th>
      <th>R06</th>
      <th>R07</th>
      <th>R08</th>
      <th>R09</th>
      <th>R10</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td><strong>R01</strong></td>
      <td>—</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>⚠️</td>
      <td>⚠️</td>
    </tr>
    <tr>
      <td><strong>R02</strong></td>
      <td>✅</td>
      <td>—</td>
      <td>✅</td>
      <td>🔴</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>⚠️</td>
      <td>⚠️</td>
    </tr>
    <tr>
      <td><strong>R03</strong></td>
      <td>✅</td>
      <td>✅</td>
      <td>—</td>
      <td>🔴</td>
      <td>✅</td>
      <td>✅</td>
      <td>🔴</td>
      <td>✅</td>
      <td>⚠️</td>
      <td>⚠️</td>
    </tr>
    <tr>
      <td><strong>R04</strong></td>
      <td>✅</td>
      <td>🔴</td>
      <td>🔴</td>
      <td>—</td>
      <td>✅</td>
      <td>✅</td>
      <td>🔴</td>
      <td>✅</td>
      <td>⚠️</td>
      <td>⚠️</td>
    </tr>
    <tr>
      <td><strong>R05</strong></td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>—</td>
      <td>🔴</td>
      <td>✅</td>
      <td>✅</td>
      <td>⚠️</td>
      <td>⚠️</td>
    </tr>
    <tr>
      <td><strong>R06</strong></td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>🔴</td>
      <td>—</td>
      <td>✅</td>
      <td>✅</td>
      <td>⚠️</td>
      <td>⚠️</td>
    </tr>
    <tr>
      <td><strong>R07</strong></td>
      <td>✅</td>
      <td>✅</td>
      <td>🔴</td>
      <td>🔴</td>
      <td>✅</td>
      <td>✅</td>
      <td>—</td>
      <td>✅</td>
      <td>⚠️</td>
      <td>⚠️</td>
    </tr>
    <tr>
      <td><strong>R08</strong></td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>✅</td>
      <td>—</td>
      <td>✅</td>
      <td>✅</td>
    </tr>
    <tr>
      <td><strong>R09</strong></td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>✅</td>
      <td>—</td>
      <td>🔴</td>
    </tr>
    <tr>
      <td><strong>R10</strong></td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>⚠️</td>
      <td>✅</td>
      <td>🔴</td>
      <td>—</td>
    </tr>
  </tbody>
</table>

---

## Critical SoD Conflicts Explained

### Conflict 1 — Accounts Payable Officer + Payment Processor (R03 + R04)
**Why it's critical:** A user who can both create vendor invoices AND 
release payments has end-to-end control of the payment cycle. This is 
the highest fraud risk in any financial ERP — a single user could create 
a fictitious invoice and process payment to an account they control.

**Technical control:** Entra ID app roles `D365.AP.Officer` and 
`D365.AP.PaymentProcessor` are mutually exclusive — assignment of one 
blocks assignment of the other via Entitlement Management policy.

**Compensating control (if business requires exception):** Dual 
authorisation workflow in D365, daily payment reconciliation by Finance 
Manager, and real-time Sentinel alert on same-user invoice-to-payment 
sequence.

---

### Conflict 2 — Finance Manager + Payment Processor (R02 + R04)
**Why it's critical:** A Finance Manager who can also release payments 
can approve their own payment transactions, bypassing the approval 
workflow entirely.

**Technical control:** App roles `D365.Finance.Manager` and 
`D365.AP.PaymentProcessor` are mutually exclusive.

---

### Conflict 3 — Vendor Master Maintainer + Payment Processor (R07 + R04)
**Why it's critical:** The classic payment fraud vector — a user who 
can modify vendor bank account details AND process payments can redirect 
legitimate supplier payments to a fraudulent account.

**Technical control:** App roles `D365.Vendor.Maintainer` and 
`D365.AP.PaymentProcessor` are mutually exclusive.

**Detection:** Sentinel rule fires on any vendor bank detail change 
followed by a payment to that vendor within 48 hours.

---

### Conflict 4 — Vendor Master Maintainer + Accounts Payable Officer (R07 + R03)
**Why it's critical:** A user who can create vendors AND create invoices 
for those vendors can fabricate the entire accounts payable chain up to 
(but not including) payment release.

**Technical control:** Mutually exclusive app roles.

---

### Conflict 5 — Procurement Officer + Procurement Approver (R05 + R06)
**Why it's critical:** Self-approval of purchase orders bypasses the 
financial authorisation framework entirely — a user could raise and 
approve their own purchases.

**Technical control:** D365 workflow engine blocks self-approval at 
the application layer. Entra ID app roles enforce the separation at 
the identity layer as an additional control.

---

### Conflict 6 — ERP System Admin + Global Admin (R09 + R10)
**Why it's critical:** Combining ERP system administration with Entra ID 
tenant administration creates an account with effectively unrestricted 
control over both the identity plane and the application plane — a 
catastrophic blast radius if compromised.

**Technical control:** PIM role assignments are mutually exclusive. 
A user cannot activate both roles simultaneously. Separate approval 
workflows required for each.

---

## Access Package Design

Entra ID Entitlement Management access packages enforce the SoD 
constraints at the provisioning layer:

| Package Name | Roles Included | Approver | Review Frequency |
|---|---|---|---|
| Finance Standard | R01 | Line Manager | Annual |
| Finance Management | R02 | CFO | Quarterly |
| Accounts Payable | R03 | Finance Manager | Quarterly |
| Payment Processing | R04 | CFO + CISO | Quarterly |
| Procurement Standard | R05 | Line Manager | Annual |
| Procurement Approval | R06 | CPO | Quarterly |
| Vendor Management | R07 | Finance Manager | Quarterly |
| Audit Read-Only | R08 | CISO | Annual |
| ERP Admin (JIT) | R09 | CISO + CTO | Per activation |

**SoD enforcement at package level:** The Entitlement Management 
policy is configured to block assignment of incompatible packages 
to the same user. Attempting to assign R03 and R04 to the same 
user will fail at the policy layer before any role is granted.

---

## Compensating Controls for Approved Exceptions

In rare cases where a business requirement demands a temporary SoD 
exception (e.g. small team during an incident):

1. **Formal exception request** approved by CISO and CFO
2. **Time-limited access** — maximum 5 business days via PIM
3. **Enhanced monitoring** — Sentinel workbook enabled for 
   all actions by the excepted user during the exception period
4. **Post-exception review** — all transactions during the 
   exception period reviewed by Risk Auditor within 5 days
5. **Exception register** maintained by Risk & Compliance team

---

## Access Review Process

| Role Tier | Review Frequency | Reviewer | Action on No Response |
|---|---|---|---|
| Standard (R01, R05) | Annual | Line Manager | Access removed after 14 days |
| Elevated (R02, R03, R06, R07) | Quarterly | Department Head | Access removed after 7 days |
| Privileged (R04, R08) | Quarterly | CISO | Access removed after 7 days |
| Admin (R09, R10) | Monthly | CISO + CTO | Access removed after 3 days |

Access reviews are automated via Entra ID Access Reviews. 
Reviewers receive email notifications with a direct link to 
approve or revoke. Non-response results in automatic revocation 
per the schedule above.

---

## SoD Violation Response

If a SoD violation is detected (e.g. via Sentinel alert or 
manual audit finding):

1. **Immediate** — Sentinel alert fires, security team notified
2. **Within 1 hour** — Conflicting role identified and removed 
   by security team
3. **Within 24 hours** — All transactions performed during the 
   violation window reviewed by Risk Auditor
4. **Within 5 days** — Root cause analysis completed, 
   remediation documented
5. **Within 30 days** — Process improvement implemented to 
   prevent recurrence

---

## Regulatory Alignment

| Regulation / Standard | SoD Requirement | How This Architecture Addresses It |
|---|---|---|
| **APRA CPS 234** | Information security controls proportional to risk | Technical SoD enforcement via Entra ID + D365 |
| **APRA CPG 234** | Access controls and privilege management | PIM for admin, access reviews, least privilege |
| **ISO 27001 A.9.2** | User access provisioning and deprovisioning | SCIM + Entitlement Management lifecycle |
| **ISO 27001 A.9.3** | Management of privileged access rights | PIM JIT, quarterly reviews |
| **SOX (equivalent)** | Financial reporting integrity controls | SoD matrix, dual authorisation, audit trail |
| **VPDSF VPDSS** | ICT security and personnel security standards | Role-based access, lifecycle management |

---

*Last updated: June 2026 | Author: Jonar*
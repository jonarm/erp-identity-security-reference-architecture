# ADR-003: Microsoft Defender for Cloud Apps Session Controls for Unmanaged Devices

*Author: Jonar | Repository: [jonarm](https://github.com/jonarm)*  
*Status: Accepted*  
*Date: June 2026*  
*Deciders: Security Architecture, Identity Team, CISO*

---

## Context

Contoso Financial Services staff occasionally access Dynamics 365 Finance 
and Operations from devices that are not enrolled in Intune and therefore 
not subject to the organisation's device compliance baseline. These 
scenarios include:

- Contractors and third-party vendors using personal laptops
- Staff accessing D365 from a personal home device during approved 
  remote work
- Executive access from a personal mobile device
- Emergency access from a non-corporate device during an incident

The organisation cannot block all unmanaged device access without 
significant operational impact. However, permitting unrestricted access 
from unmanaged devices creates material risk:

- Unmanaged devices may be compromised by malware or keyloggers
- Data downloaded to unmanaged devices cannot be controlled or wiped
- DLP policies enforced on managed devices do not apply
- Session tokens on unmanaged devices may be extracted and replayed

A decision is required on how Microsoft Defender for Cloud Apps (MCAS) 
Conditional Access App Control should be configured to manage this 
risk without blocking legitimate access entirely.

---

## Decision Drivers

1. **Protect financial data from exfiltration via unmanaged devices** —
   bulk download of ERP data to a personal device is a primary insider 
   threat vector
2. **Maintain operational access for legitimate unmanaged device scenarios** —
   a blanket block is operationally unacceptable
3. **Apply controls proportional to device risk** — unmanaged devices 
   should receive a degraded but functional experience, not full access
4. **Ensure controls are transparent to end users** — session controls 
   should not break the D365 user experience
5. **Create visibility into unmanaged device activity** — all sessions 
   from unmanaged devices should be monitored
6. **Align to NIST 800-207 Zero Trust** — device compliance is a 
   signal in the access decision, not a binary gate

---

## Options Considered

### Option 1 — Block All Unmanaged Device Access

Configure Conditional Access policy CA003 to require a compliant 
Intune-enrolled device for all Dynamics 365 access. Any session from 
an unmanaged device is blocked at the CA layer before reaching D365.

**Strengths:**
- Simplest to implement and explain
- Maximum data protection — no ERP data reaches unmanaged devices
- No MCAS configuration required

**Weaknesses:**
- Blocks all contractor, vendor, and emergency access from personal devices
- Significant operational friction — requires device enrolment for 
  all third parties
- Does not align to Zero Trust principle of granular access decisions 
  based on multiple signals
- Creates pressure to add exceptions that erode the control over time

**Decision: Rejected** — operationally unacceptable for a financial 
services organisation with significant contractor and vendor workforce.

---

### Option 2 — Unrestricted Access from Unmanaged Devices with Monitoring Only

Permit full D365 access from unmanaged devices. Deploy MCAS in 
Discovery mode to log activity but apply no session restrictions. 
Alert on anomalous behaviour.

**Strengths:**
- No operational friction
- Full visibility into unmanaged device activity

**Weaknesses:**
- Data downloaded to unmanaged devices is completely uncontrolled
- Monitoring alone is a detective control — does not prevent exfiltration
- Does not satisfy VPDSF information security requirements
- Fails APRA CPS 234 proportional control obligations for financial data

**Decision: Rejected** — monitoring without prevention is insufficient 
for financial ERP data.

---

### Option 3 — MCAS Conditional Access App Control with Session Restrictions

Route all Dynamics 365 sessions from unmanaged devices through the 
MCAS reverse proxy. Apply session policies that:

- **Block file downloads** — prevent bulk export of financial data 
  to unmanaged devices
- **Block copy/paste of sensitive data** — prevent screen scraping 
  of financial records
- **Apply watermarking** — visible watermark on all D365 screens 
  during unmanaged device sessions
- **Monitor all activity** — full session logging in MCAS activity log
- **Alert on anomalous behaviour** — bulk query, unusual access 
  patterns, after-hours access

Users on unmanaged devices can view and interact with D365 but cannot 
download or extract data. Full functionality is retained for managed 
device sessions.

**Strengths:**
- Balances access and data protection — operational access preserved
- Prevents the primary exfiltration vector (bulk download) without 
  blocking all access
- Full session visibility and audit trail
- Watermarking creates accountability and deters insider misuse
- Aligns to Zero Trust — device compliance is a signal that modifies 
  access scope, not a binary gate
- Satisfies VPDSF information security and APRA CPS 234 requirements

**Weaknesses:**
- More complex to configure than Options 1 or 2
- MCAS reverse proxy introduces a small latency overhead
- Some D365 functionality may behave differently when proxied — 
  requires testing
- Requires Entra ID P1 minimum and MCAS licensing

**Decision: Accepted**

---

### Option 4 — Option 3 Plus Step-Up Authentication for Sensitive Modules

Extend Option 3 by requiring step-up MFA re-authentication when an 
unmanaged device session attempts to access sensitive D365 modules 
(accounts payable, payment processing, vendor master).

**Decision: Accepted as an enhancement to Option 3**

---

## Decision

**Selected: Option 3 + Option 4 — MCAS Session Controls with 
Step-Up Authentication for Sensitive Modules**

---

## MCAS Configuration Specification

### Step 1 — Conditional Access Policy (CA006)

Configure CA006 to route unmanaged device sessions through MCAS:

| Parameter | Value |
|---|---|
| Policy name | CA006 — MCAS Session Control for Unmanaged Devices |
| Users | All users |
| Cloud apps | Dynamics 365 Finance and Operations |
| Conditions | Device: not marked as compliant AND not Entra joined |
| Grant | Grant access — require MFA |
| Session | Use Conditional Access App Control — Use custom policy |

This policy intercepts all D365 sessions from unmanaged devices 
and routes them through the MCAS reverse proxy without blocking access.

---

### Step 2 — MCAS Session Policies

#### Policy 1 — Block File Downloads on Unmanaged Devices

| Parameter | Value |
|---|---|
| Policy name | Block D365 Downloads — Unmanaged Devices |
| Session type | Control file download with inspection |
| Filter | Device: unmanaged |
| App | Dynamics 365 |
| Action | Block download |
| Alert | Generate alert on block event |
| Severity | Medium |

---

#### Policy 2 — Block Cut/Copy of Financial Data

| Parameter | Value |
|---|---|
| Policy name | Block D365 Clipboard — Unmanaged Devices |
| Session type | Block activities |
| Filter | Device: unmanaged |
| Activity | Cut, Copy |
| App | Dynamics 365 |
| Action | Block |
| Alert | Generate alert on repeated block events (5+ in session) |

---

#### Policy 3 — Watermark Financial Data on Unmanaged Devices

| Parameter | Value |
|---|---|
| Policy name | Watermark D365 — Unmanaged Devices |
| Session type | Control file download with inspection |
| Filter | Device: unmanaged |
| App | Dynamics 365 |
| Action | Protect — apply watermark |
| Watermark content | Username + date/time + "CONTOSO CONFIDENTIAL" |

Watermarking applies to any content viewed or printed during 
an unmanaged device session, creating a deterrent and an 
evidence trail for any screenshots taken.

---

#### Policy 4 — Alert on Anomalous Unmanaged Device Activity

| Parameter | Value |
|---|---|
| Policy name | Anomaly Alert — D365 Unmanaged Device Session |
| Session type | Monitor all activities |
| Filter | Device: unmanaged |
| Anomaly triggers | Bulk query (100+ records), after-hours access, new country sign-in |
| Action | Alert security team |
| Severity | High |

---

### Step 3 — Step-Up Authentication for Sensitive Modules

For unmanaged device sessions attempting to access accounts payable, 
payment processing, or vendor master modules:

| Parameter | Value |
|---|---|
| Trigger | Navigation to sensitive D365 module URL patterns |
| Action | Require step-up MFA re-authentication via Entra ID |
| MFA method | Authenticator app or FIDO2 |
| Session validity | Step-up valid for 30 minutes before re-prompt |

This is implemented via MCAS session policy combined with 
Conditional Access authentication context — a feature that 
allows granular MFA requirements within an already-authenticated 
session based on the specific resource being accessed.

---

## User Experience Impact

### Managed Device Users
- No change to experience
- Full D365 functionality including file downloads and exports
- No MCAS proxy overhead

### Unmanaged Device Users
- Sign-in experience unchanged — MCAS proxy is transparent
- D365 interface fully functional for viewing and data entry
- Download buttons disabled — user sees a block notification
- Watermark visible on all screens
- Step-up MFA prompt when accessing sensitive modules
- User receives a clear message explaining why downloads are blocked 
  and how to access from a managed device

---

## Monitoring and Alerting Integration

MCAS session control events are ingested into Microsoft Sentinel 
via the Defender for Cloud Apps data connector:

| MCAS Event | Sentinel Rule | Action |
|---|---|---|
| File download blocked | `erp-bulk-data-export.json` | Alert security team |
| Anomalous session activity | MCAS anomaly detection | Alert + investigate |
| Sensitive module access from unmanaged device | Custom alert | Log + notify |
| High volume clipboard block events | Custom alert | Investigate insider risk |

---

## Consequences

### Positive
- Financial data protected from download to unmanaged devices 
  without blocking operational access
- Full session visibility — every unmanaged device session is 
  logged and available for investigation
- Watermarking creates accountability and legal evidentiary value
- Step-up MFA for sensitive modules adds a proportional control 
  layer for the highest-risk ERP functions
- Aligns to Zero Trust — device state modifies access scope 
  rather than acting as a binary gate
- Satisfies VPDSF information security domain requirements
- Satisfies APRA CPS 234 Para 19 proportional control requirements

### Negative
- MCAS reverse proxy introduces configuration complexity
- Some D365 features may require testing to confirm MCAS 
  compatibility — particularly Excel add-in and Power BI integration
- Users may find download blocking frustrating without clear 
  communication of the reason
- MCAS licensing required — included in M365 E5 and Entra ID P2 
  bundles but must be verified

### Risks and Mitigations

| Risk | Mitigation |
|---|---|
| MCAS proxy breaks D365 functionality | Full UAT on unmanaged device before go-live; test all key workflows |
| Users circumvent via screen recording | Watermarking provides evidentiary trail; acceptable residual risk |
| MCAS latency impacts user experience | MCAS proxy adds <200ms latency in most regions; acceptable for ERP use |
| Policy misconfiguration allows download | Tested in attack simulation Scenario 2; Sentinel alert as backstop |
| Contractor resistance to watermarking | Contractual obligation to accept monitoring; communicated at onboarding |

---

## Testing Requirements

Before go-live, the following must be validated in the lab environment:

- [ ] Unmanaged device session successfully routed through MCAS proxy
- [ ] File download blocked and block notification displayed correctly
- [ ] Watermark applied correctly to D365 screens
- [ ] Step-up MFA prompt fires on sensitive module navigation
- [ ] Managed device session unaffected by MCAS policies
- [ ] MCAS activity log captures full session detail
- [ ] Sentinel alert fires on simulated bulk download attempt
- [ ] SOAR playbook triggers correctly on download block alert
- [ ] D365 Excel add-in behaviour documented on unmanaged devices
- [ ] D365 Power BI integration behaviour documented

---

## Related Decisions
- [ADR-001: SSO Protocol Selection](ADR-001-sso-saml-vs-oidc.md)
- [ADR-002: PIM for ERP Admin Roles](ADR-002-pim-for-erp-admin.md)
- [ADR-004: SCIM vs Manual Provisioning](ADR-004-scim-vs-manual-provisioning.md)

---

## References
- Microsoft Docs: Conditional Access App Control with MCAS
- Microsoft Docs: Deploy Cloud App Security Conditional Access App Control
- NIST SP 800-207: Zero Trust Architecture
- APRA CPS 234: Information Security
- VPDSF: Information Security Domain

---

*Last updated: June 2026 | Author: Jonar*
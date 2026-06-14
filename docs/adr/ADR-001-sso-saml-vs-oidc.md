# ADR-001: SSO Protocol Selection — SAML 2.0 vs OIDC for Dynamics 365

*Author: Jonar | Repository: [jonarm](https://github.com/jonarm)*  
*Status: Accepted*  
*Date: June 2026*  
*Deciders: Security Architecture, Identity Team*

---

## Context

Contoso Financial Services is integrating Microsoft Dynamics 365 Finance 
and Operations with Entra ID as the Identity Provider (IdP) for Single 
Sign-On (SSO). A protocol decision is required between the two dominant 
SSO standards:

- **SAML 2.0** (Security Assertion Markup Language)
- **OIDC** (OpenID Connect, built on OAuth 2.0)

This decision affects how authentication tokens are issued, how session 
management works, how Conditional Access policies are enforced, and how 
the architecture supports future SaaS application onboarding.

This is a foundational architectural decision — changing SSO protocol 
post-deployment requires significant re-configuration of both the IdP 
and the application, and impacts all downstream access controls.

---

## Decision Drivers

1. **Native Dynamics 365 F&O support** — the protocol must be natively 
   supported by D365 F&O without custom middleware
2. **Conditional Access enforcement** — the protocol must allow Entra ID 
   to enforce CA policies at every authentication event
3. **Token security** — the protocol must support modern token binding 
   and short-lived token lifetimes
4. **Session management** — the protocol must support single logout (SLO) 
   to terminate ERP sessions when Entra ID session is revoked
5. **Future extensibility** — the protocol choice should support future 
   SaaS app onboarding without re-architecture
6. **Developer and tooling ecosystem** — availability of libraries, 
   debugging tools, and community support

---

## Options Considered

### Option 1 — SAML 2.0

SAML 2.0 is an XML-based authentication and authorisation standard 
widely adopted in enterprise environments since the mid-2000s. It uses 
signed XML assertions passed between the IdP (Entra ID) and the 
Service Provider (Dynamics 365).

**How it works in this context:**
1. User attempts to access Dynamics 365
2. D365 redirects user to Entra ID with a SAML AuthnRequest
3. Entra ID authenticates the user (MFA, CA policy evaluation)
4. Entra ID returns a signed SAML Assertion to D365
5. D365 validates the assertion and grants access

**Strengths:**
- Mature, battle-tested protocol with 20+ years of enterprise adoption
- Native support in Dynamics 365 F&O as the preferred enterprise SSO method
- Broad support across legacy and modern SaaS applications
- Well-understood by enterprise security and audit teams
- SAML assertions contain rich attribute claims for role mapping
- Single Logout (SLO) well-supported for session termination

**Weaknesses:**
- XML-based — verbose, complex to debug
- Not natively suited for mobile or API-based access flows
- Token format not compatible with modern OAuth 2.0 API authorisation
- Larger attack surface — XML signature wrapping attacks are a known risk
- SAML assertions are larger and more complex than JWT tokens

---

### Option 2 — OpenID Connect (OIDC)

OIDC is a modern identity layer built on top of OAuth 2.0, using 
JSON Web Tokens (JWTs). It is the protocol of choice for cloud-native 
and API-first applications.

**How it works in this context:**
1. User attempts to access Dynamics 365
2. D365 redirects user to Entra ID with an OIDC authorisation request
3. Entra ID authenticates the user (MFA, CA policy evaluation)
4. Entra ID returns an ID Token (JWT) and Access Token to D365
5. D365 validates the JWT and grants access

**Strengths:**
- Modern, lightweight JSON/JWT-based tokens — easy to inspect and debug
- Native support for API authorisation via OAuth 2.0 access tokens
- Better suited for mobile, SPA, and API-first access patterns
- Shorter token lifetimes natively supported — reduced window of token abuse
- Continuous Access Evaluation (CAE) supported — real-time token revocation
- Growing adoption as the default for new SaaS applications

**Weaknesses:**
- Dynamics 365 F&O's primary enterprise SSO integration path is SAML — 
  OIDC support in F&O requires additional configuration consideration
- Single Logout (SLO) less mature than SAML in some implementations
- OAuth 2.0 complexity — more grant types and flows to manage correctly

---

### Option 3 — Both (Hybrid)

Implement SAML 2.0 for the primary Dynamics 365 F&O user authentication 
flow, and OIDC for service principal and API-based integrations 
(Power Platform, Azure Data Lake, third-party connectors).

---

## Decision

**Selected: Option 3 — Hybrid (SAML 2.0 for user SSO, OIDC for API/service principal flows)**

### Rationale

**SAML 2.0 for user authentication:**
Dynamics 365 F&O's enterprise SSO integration is most mature and 
well-documented using SAML 2.0 via Entra ID. The financial services 
context adds an additional consideration — SAML's rich assertion 
attributes allow ERP role claims to be passed directly in the assertion, 
enabling precise role mapping to the SoD-constrained app roles defined 
in this architecture. Audit teams and compliance stakeholders are also 
more familiar with SAML-based SSO in financial services contexts.

**OIDC for API and service principal flows:**
All programmatic access to Dynamics 365 APIs (OData, Power Platform 
connectors, Azure Data Lake integration) uses OAuth 2.0 client 
credentials flow with OIDC tokens. This is the Microsoft-recommended 
approach for service-to-service integration and is required for 
Continuous Access Evaluation (CAE) support — enabling real-time 
session revocation when a service principal's risk level changes.

This hybrid approach is consistent with Microsoft's own guidance for 
enterprise Dynamics 365 deployments and provides the cleanest 
separation between human user authentication and machine-to-machine 
authorisation.

---

## Consequences

### Positive
- Optimal protocol for each access pattern — no compromise on either 
  user experience or API security
- SAML role claims enable direct SoD enforcement at the IdP layer
- OIDC for APIs enables CAE and short-lived token enforcement
- Aligns with Microsoft's documented best practice for D365 + Entra ID
- Audit-friendly — SAML assertions are well-understood by financial 
  services auditors

### Negative
- Two protocols to maintain and monitor — increases operational complexity
- Security team must be proficient in both SAML assertion debugging 
  and OAuth 2.0 token inspection
- SAML Single Logout (SLO) must be explicitly configured and tested — 
  it is not enabled by default in all D365 configurations

### Risks and Mitigations

| Risk | Mitigation |
|---|---|
| SAML assertion interception | Assertions signed and encrypted; TLS 1.2+ enforced on all endpoints |
| XML signature wrapping attack | Entra ID handles assertion signing — not exposed to custom XML processing |
| OAuth token leakage via `.env` files | Client secrets stored in Azure Key Vault only; enforced via IaC policy |
| SLO not functioning — stale ERP sessions | SLO tested in attack simulation Scenario 3; Sentinel alert on session anomaly |
| Protocol misconfiguration during onboarding | All configuration deployed via Terraform — no manual portal changes |

---

## Implementation Notes

### SAML Configuration (Entra ID → Dynamics 365)
- Entity ID: `https://d365.contosofinancial.com`
- Reply URL (ACS): `https://d365.contosofinancial.com/auth/saml/callback`
- Sign-on URL: `https://d365.contosofinancial.com`
- Signing certificate: 3-year validity, rotation automated via Key Vault
- Claims mapping:
  - `user.userprincipalname` → NameID
  - `user.assignedroles` → D365 role claim
  - `user.department` → Department attribute

### OIDC Configuration (Service Principals)
- Grant type: Client Credentials (no user interaction)
- Token lifetime: 1 hour maximum
- Scope: Minimum required D365 API permissions only
- Secret storage: Azure Key Vault — never in code or environment files

---

## Related Decisions
- [ADR-002: PIM Configuration for ERP Admin Roles](ADR-002-pim-for-erp-admin.md)
- [ADR-003: MCAS Session Controls for Unmanaged Devices](ADR-003-mcas-session-controls.md)
- [ADR-004: SCIM vs Manual Provisioning](ADR-004-scim-vs-manual-provisioning.md)

---

## References
- Microsoft Docs: Configure SAML-based SSO for Dynamics 365
- NIST SP 800-63C: Federation and Assertions
- OWASP: SAML Security Cheat Sheet
- Microsoft Identity Platform: OIDC and OAuth 2.0

---

*Last updated: June 2026 | Author: Jonar*
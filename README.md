# APEX Mobility Group IAM Engineering

Enterprise-style Identity & Access Management engineering portfolio built around a fictional mobility technology and transportation services company.

## Purpose

This repository documents hands-on IAM engineering work across Microsoft Entra ID, Microsoft Graph, PowerShell, Conditional Access, SAML federation, identity lifecycle automation, troubleshooting, validation, and operational documentation.

The goal is not to collect isolated demos. Each ticket follows an engineering workflow:

**Discover → Assess → Design → Build → Validate → Troubleshoot → Automate → Document → Handoff**

## Portfolio highlights

**Current status:** IAM-1054 and IAM-1055 completed and documented. Break/fix federation tickets and the reusable JML Automation Toolkit are next.

## Current showcase tickets

### IAM-1054 — Conditional Access MFA + Session Controls
Built and validated a pilot Conditional Access policy with MFA enforcement, emergency-access exclusion, report-only testing, controlled enablement, 1-hour sign-in frequency, session-expiration validation, error 70044 troubleshooting, and rollback planning.

[View IAM-1054](tickets/IAM-1054-conditional-access-mfa/README.md)

### IAM-1055 — SAML 2.0 SSO Integration + Claims Troubleshooting
Designed a RouteSphere federation scenario, used Microsoft Entra SAML Toolkit as the live Service Provider for realistic validation, configured NameID and claims, decoded the SAML response, traced a missing role claim through Microsoft Graph, remediated the app-role design, and validated `role = User` end to end.

[View IAM-1055](tickets/IAM-1055-saml-sso-integration/README.md)

## Automation

The automation section is reserved for the validated Microsoft Graph / PowerShell tooling used across the project. Actual scripts will be added from the working set rather than recreated from memory.

[View automation roadmap](automation/README.md)

## What this repository demonstrates

- Translating business requirements into IAM controls
- Building and validating authentication / authorization flows
- Troubleshooting with sign-in logs, protocol evidence, and Microsoft Graph
- Separating human approval from deterministic automation
- Documenting rollback, validation, and customer handoff

## Technologies

- Microsoft Entra ID
- Microsoft Graph
- PowerShell
- REST APIs / JSON
- Conditional Access
- SAML 2.0 SSO
- Enterprise Applications
- App Roles / RBAC
- Sign-in and audit logs
- Joiner-Mover-Leaver workflows

## Engineering principles

- Least privilege by default
- Human approval for business-risk decisions
- Automate deterministic execution and validation
- Preserve break-glass / rollback paths
- Validate with logs and protocol evidence
- Troubleshoot from evidence instead of assumptions
- Document reusable SOPs and lessons learned

## Project disclaimer

APEX Mobility Group and RouteSphere Fleet Operations are fictional scenarios created for hands-on IAM engineering practice. Microsoft Entra SAML Toolkit was used as the real Service Provider for end-to-end SAML validation where RouteSphere did not have a live SP endpoint.

## Roadmap

See [docs/project-roadmap.md](docs/project-roadmap.md) for planned break/fix federation work and IAM automation milestones.

# IAM-1055 — SAML 2.0 SSO Integration + Claims Troubleshooting

## Business scenario

RouteSphere Fleet Operations was modeled as a fictional SaaS application for APEX fleet and transportation operations. Microsoft Entra ID was the Identity Provider.

Because RouteSphere did not have a live SAML Service Provider behind the fictional Entity ID / ACS endpoints, Microsoft Entra SAML Toolkit was used as the real SP for end-to-end protocol validation.

## Objective

Validate a realistic SAML 2.0 flow including:

- Entity ID / ACS relationship
- NameID
- Identity attributes
- App roles / authorization
- Assignment control
- SP-initiated SSO
- Sign-in logs
- Decoded SAML assertion evidence

## Configuration

- IdP: Microsoft Entra ID
- SP used for validation: Microsoft Entra SAML Toolkit
- NameID: corporate email address
- Claims validated: email, department, role
- Least-privilege assignment model

## Troubleshooting story

SSO succeeded, and the decoded SAML assertion contained NameID and `department = Security`, but the expected role claim was missing.

Instead of changing claims blindly, Microsoft Graph was used to inspect the Toolkit service principal. The default role showed:

```text
msiam_access
value = null
```

That explained why the role mapping had no meaningful value to emit.

A custom app role was created:

```text
Display name: User
Value: User
```

Maya Brooks was assigned the new role, SSO was repeated, and the decoded assertion confirmed:

```text
department = Security
role = User
```

The redundant `msiam_access` assignment was then removed and a final SSO test confirmed the cleaned-up state still worked.

## Root cause

The default `msiam_access` assignment had no role value (`value = null`), so no meaningful role value appeared in the SAML assertion.

## Resolution

Create and assign a meaningful app role with a non-null value, retest the SAML flow, decode the assertion, then remove the redundant default assignment after successful validation.

## Key lesson

A successful login is only part of federation validation. IAM engineers should inspect what the Service Provider actually receives and confirm both authentication and authorization data.

## Evidence

See `evidence/` for the Toolkit configuration, claims, Graph RCA, final role assignment, and decoded assertion.

## SOP

The reusable SAML integration SOP is maintained as part of the project documentation and will be published after a final public-sanitization review.

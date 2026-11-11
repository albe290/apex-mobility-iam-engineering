# Project Roadmap

## Completed showcase tickets

- **IAM-1054** — Conditional Access MFA + session controls
- **IAM-1055** — SAML 2.0 SSO integration + claims troubleshooting

## Next federation break/fix tickets

- **IAM-1069** — SAML signing-certificate rollover / stale trust failure
- **IAM-1070** — ACS / Entity ID mismatch
- **IAM-1071** — NameID / claim-mapping failure

These tickets intentionally break known-good SAML configurations, collect evidence, identify root cause, restore service, and document rollback / prevention.

## Automation milestone

- **IAM-1058** — Refactor the existing Microsoft Graph / PowerShell scripts into a reusable Joiner-Mover-Leaver Automation Toolkit with parameters, dry-run support, idempotency, structured logging, retries, reconciliation, approval gates, and evidence generation.

## Future expansion

- Okta application onboarding and lifecycle workflows
- SCIM provisioning and reconciliation
- Access reviews / governance
- CyberArk PAM engineering scenarios
- Workload / non-human identity controls

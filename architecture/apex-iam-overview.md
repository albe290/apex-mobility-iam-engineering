# APEX Mobility Group — IAM Architecture Overview

## Organization

APEX Mobility Group is a fictional mid-sized company in the Mobility Technology & Transportation Services sector. The scenario includes fleet operations, transportation operations, connected mobility services, engineering, security, HR, finance, customer support, sales, and IT/IAM functions.

## IAM scope

The project models identity controls for:

- Workforce identities
- Enterprise application access
- SSO and federation
- MFA and Conditional Access
- RBAC and least privilege
- Joiner-Mover-Leaver lifecycle workflows
- Microsoft Graph / PowerShell automation
- Logging, troubleshooting, and evidence collection
- Future workload / non-human identity scenarios

## Design philosophy

The project separates three decision types:

1. **Automate** — deterministic execution, validation, evidence collection.
2. **Human approval/review** — entitlement decisions, privileged access, policy scope, exceptions, destructive changes.
3. **Manual-only / high-risk** — ambiguous or governance-heavy actions requiring judgment.

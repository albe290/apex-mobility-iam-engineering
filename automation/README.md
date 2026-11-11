# IAM Automation

This folder will contain the validated Microsoft Graph / PowerShell tooling used across the APEX project.

## Working-set scripts to publish

- `users.ps1` — identity inspection
- `groups.ps1` — group membership inspection
- `enable-user.ps1` — account enablement + validation
- `disable-user.ps1` — account disablement
- `add-group-member.ps1` — approved group assignment
- `remove-group-member.ps1` — approved group removal
- `validate-app-access.ps1` — application access validation
- `validate-signin.ps1` — sign-in validation
- `remove-leaver-access.ps1` — leaver access cleanup
- `update-mover-user.ps1` — mover workflow updates

## Publishing rule

Only publish scripts that have been validated in the tenant and reviewed for secrets, tenant-specific identifiers, credentials, tokens, email addresses, and other values that should not be public.

## Future IAM-1058 goal

Refactor isolated scripts into a reusable JML Automation Toolkit with:

- Parameters
- Dry-run mode
- Idempotency
- Structured logging
- Error handling / retries
- State reconciliation
- Approval gates
- Evidence generation

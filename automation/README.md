# IAM Automation

This folder is reserved for the Microsoft Graph / PowerShell tooling that is actually validated as part of the APEX IAM project.

## Confirmed completed scripts

The project record confirms these scripts were built and used:

- `users.ps1` — identity inspection with Microsoft Graph
- `groups.ps1` — group-membership queries / validation
- `enable-user.ps1` — test-user enablement workflow with access validation

## Source-code publishing status

The original literal `.ps1` source files are not currently present in the Project files or retrievable conversation artifacts available to this repository build.

They are **not recreated here from memory**. The exact validated files should be published only when the original source is recovered, so the repository does not present reconstructed code as the code that was actually tested.

## Planned automation expansion

Future JML automation work can include:

- Account disablement
- Approved group assignment / removal
- Application access validation
- Sign-in validation
- Leaver access cleanup
- Mover attribute updates

These are roadmap items until their actual source and validation evidence are available.

## Publishing rule

Only publish scripts that have been validated in the tenant and reviewed for secrets, tenant-specific identifiers, credentials, tokens, email addresses, and other values that should not be public.

## Future IAM-1058 goal

Refactor the validated scripts into a reusable JML Automation Toolkit with:

- Parameters
- Dry-run mode
- Idempotency
- Structured logging
- Error handling / retries
- State reconciliation
- Approval gates
- Evidence generation

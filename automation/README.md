# IAM Automation

This folder contains sanitized, portfolio-ready Microsoft Graph / PowerShell automation derived from the recovered APEX Mobility Group lab working set.

## Publishing status

The original PowerShell files were recovered from the working VS Code project and reviewed before publication.

The public copies are **not byte-for-byte copies** of the tenant working files. They preserve the original workflow and engineering intent while applying a public hardening pass:

- Tenant-specific `onmicrosoft.com` UPNs were replaced with `apexmobility.example` values.
- User, group, and application inputs were parameterized.
- Exact-object checks were added where display-name lookups could return zero or multiple objects.
- Mutating workflows now require explicit human approval before the write.
- `-ErrorAction Stop` and failure handling were added around important Graph operations.
- Post-change validation was retained or strengthened.
- A leaver safety defect was corrected so the workflow actually stops when the target account is still enabled.
- Spelling / labeling issues were cleaned up without changing the scenario intent.

No client secrets, access tokens, passwords, or hard-coded GUIDs were found in the recovered source.

## Structure

### `identity/`

- `users.ps1` — read-only identity inspection
- `validate-user.ps1` — identity + group validation
- `enable-user.ps1` — controlled account enablement with final-state validation
- `disable-user.ps1` — controlled account disablement with final-state validation

### `access/`

- `groups.ps1` — group-membership inspection
- `add-group-member.ps1` — idempotent group assignment with approval and validation
- `remove-group-member.ps1` — mover entitlement removal while preserving required access
- `validate-app-access.ps1` — validates the entitlement chain: user → group → enterprise application

### `lifecycle/`

- `remove-leaver-access.ps1` — approved leaver access revocation with safety gate and residual-access validation
- `update-mover-user.ps1` — mover attribute + manager update with preservation checks

### `validation/`

- `validate-signin.ps1` — retrieves recent Entra sign-ins and classifies the latest application result

## Validation status

The project record already confirms `users.ps1`, `groups.ps1`, and `enable-user.ps1` were built and exercised during the APEX automation work.

The remaining files are recovered members of the working set and include their original validation patterns, but the **hardened public copies should be re-tested in the lab before being described as production-ready or as byte-identical validated artifacts**.

That distinction is intentional: this repository documents real hands-on work without overstating the validation status of code that was modified for safe public release.

## Engineering pattern

The scripts follow the same APEX operating model:

**Inspect → Validate Preconditions → Human Approval → Execute → Re-query → Validate Final State**

This is the automation boundary used throughout the project: deterministic execution can be automated, while business-risk decisions and privileged changes retain a human approval gate.

## Microsoft Graph permissions

Required Graph permissions vary by script and should be granted using least privilege. Examples include user/group read permissions, user/group write permissions for approved lifecycle changes, service-principal assignment read permissions, and audit-log read permissions for sign-in validation.

## Not production-ready by default

These are portfolio/lab automation examples. Before production use they would still need environment-specific review for:

- Authentication model / managed identity
- Least-privilege Graph permissions
- Structured logging and evidence retention
- Retry / throttling handling
- Centralized configuration
- Dry-run support
- Change-ticket integration
- Rollback and compensating actions
- Unit / integration testing

## IAM-1058 direction

The next refactor is a reusable JML Automation Toolkit that turns these working scripts into composable functions with shared validation, logging, dry-run behavior, and evidence generation.

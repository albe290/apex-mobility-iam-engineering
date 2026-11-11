# Automation Boundaries

Before automating an IAM workflow, classify each action.

## Automate

Good candidates include:

- Read-only identity inspection
- Group membership checks
- Approved account enable/disable actions
- Approved group assignment/removal
- Session revocation after an approved leaver event
- Sign-in and audit-log collection
- Configuration drift checks
- Certificate-expiry checks
- Expected-vs-configured endpoint validation
- Post-change reconciliation

## Human approval / review

Keep humans in the loop for:

- Business entitlement approval
- Privileged access approval
- Conditional Access scope and enforcement decisions
- Federation trust design
- NameID / claim requirements
- Cutover timing
- Exception handling
- Destructive rollback decisions

## Manual-only / high-risk

Examples include ambiguous access conflicts, legal/HR exceptions, emergency credential handling, and changes where the blast radius is not well understood.

# IAM-1054 — Conditional Access MFA + Session Controls

## Objective

Replace broad/default authentication behavior with a controlled Microsoft Entra Conditional Access MFA pilot while preserving emergency access and validating session behavior.

## Engineering work

- Validated emergency-access account and exclusion path
- Created / used `GRP-CA-MFA-Pilot`
- Added pilot user Maya Brooks
- Transitioned from Security Defaults to Conditional Access
- Tested policy in Report-only before enforcement
- Enabled MFA enforcement for the scoped pilot
- Added 1-hour Sign-in Frequency with periodic reauthentication
- Validated session expiration and successful reauthentication
- Reviewed Entra sign-in logs and Conditional Access evaluation

## Troubleshooting / evidence

Baseline validation showed an existing MFA claim could be reused even while Conditional Access still enforced the MFA grant.

After enabling 1-hour Sign-in Frequency, the session eventually failed with:

**Error 70044 — session expired or invalid due to sign-in frequency checks by Conditional Access.**

A subsequent sign-in succeeded, proving session-policy enforcement and recovery.

## Key lesson

**MFA satisfaction and session lifetime are separate controls.** A valid MFA claim does not mean the session can persist indefinitely.

## Rollback

Use the excluded emergency-access account to disable the Conditional Access policy and review sign-in logs before restoring service.

## Evidence

Screenshots in `evidence/` document the emergency-access safeguard, pilot scoping, Report-only evaluation, policy enforcement, MFA satisfaction, the 1-hour Sign-in Frequency configuration, and error 70044 session-expiration behavior.

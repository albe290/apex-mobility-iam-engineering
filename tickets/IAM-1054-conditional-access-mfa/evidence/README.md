# IAM-1054 Evidence Guide

This public evidence set documents the Conditional Access MFA pilot from initial safety controls through enforcement and session validation. Tenant-specific identifiers, account identifiers, object IDs, and sign-in event IDs were redacted before publication.

## Core Conditional Access build and validation

### 1. Break-glass Global Administrator validated

![Break-glass Global Administrator validated](01-break-glass-global-admin-validated.jpg)

Validated the emergency-access account and Global Administrator role before changing tenant-wide authentication controls.

### 2. MFA pilot group scoped to Maya Brooks

![CA MFA pilot group](02-ca-mfa-pilot-group-maya-brooks.jpg)

Confirmed Maya Brooks as the pilot identity in `GRP-CA-MFA-Pilot`, limiting the initial Conditional Access blast radius.

### 3. CA policy staged in Report-only

![CA policy report-only](03-ca-require-mfa-pilot-report-only.jpg)

Created `CA-Require-MFA-Pilot` with the MFA grant control and staged it in Report-only before enforcement.

### 4. Report-only evaluation captured

![Report-only evaluation](04-report-only-user-action-required.jpg)

Used sign-in logs to confirm how the pilot policy would evaluate before turning it on.

### 5. CA policy enabled

![CA policy enabled](05-ca-require-mfa-pilot-enabled.jpg)

Moved the validated pilot policy from Report-only to On after reviewing the expected impact.

### 6. Conditional Access success

![Conditional Access success](06-conditional-access-success.jpg)

Confirmed the enforced policy evaluated successfully during the pilot sign-in.

### 7. MFA requirement satisfied

![MFA authentication details](07-authentication-details-mfa-satisfied.jpg)

Authentication Details showed the MFA requirement was satisfied by a previously satisfied authentication claim.

## Session-control extension

### 8. Sign-in Frequency configured to 1 hour

![IAM-1054 Sign-in Frequency](08-sign-in-frequency-1-hour.webp)

Added a 1-hour Sign-in Frequency with periodic reauthentication to test session-lifetime behavior separately from MFA satisfaction.

### 9. Session expiration — Error 70044

![IAM-1054 Error 70044](09-session-expiration-error-70044.jpg)

Captured the expected session-expiration event caused by the Sign-in Frequency control.

## Key engineering lesson

**MFA satisfaction and session lifetime are separate controls.** A user can satisfy the MFA grant through an existing claim while Conditional Access still forces periodic session reevaluation through Sign-in Frequency.

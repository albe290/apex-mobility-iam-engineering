# IAM-1054 Evidence Guide

This public evidence set is a sanitized subset of the original IAM-1054 screenshots. Tenant-specific identifiers and account details were removed before publication.

## Published evidence

### 1. Sign-in Frequency configured to 1 hour

![IAM-1054 Sign-in Frequency](02-sign-in-frequency-1-hour.webp)

Shows the Conditional Access session control configured for a 1-hour Sign-in Frequency with periodic reauthentication.

### 2. Session expiration — Error 70044

![IAM-1054 Error 70044](03-error-70044.webp)

Shows the expected session-expiration behavior after the Sign-in Frequency control was enforced.

## Validation story

The baseline session remained usable until the configured Sign-in Frequency required reevaluation. The subsequent 70044 event provided evidence that session lifetime was being enforced independently from the user's existing MFA claim.

Additional original screenshots are retained outside the public repository.

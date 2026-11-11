# SAML 2.0 Enterprise Application Integration SOP

> **Public portfolio edition.** Tenant-specific identifiers, object IDs, request/correlation IDs, IP addresses, certificate metadata, and real administrative UPNs have been redacted. APEX Mobility Group and RouteSphere are fictional learning-environment scenarios. Microsoft Entra SAML Toolkit was used as the real Service Provider validation harness for end-to-end SAML testing.

**Microsoft Entra ID as Identity Provider \| APEX Mobility Group**

Reference implementation: RouteSphere Fleet Operations design with Microsoft Entra SAML Toolkit used as the real Service Provider validation harness. \| v1.2 adds the IAM-1055 screenshot walkthrough.

| **SOP ID**         | IAM-SAML-001                                        |
|--------------------|-----------------------------------------------------|
| **Version**        | 1.2                                                 |
| **Effective Date** | November 3, 2026                                    |
| **Owner**          | IAM Engineering                                     |
| **Related Ticket** | IAM-1055 — Entra SAML SSO Configuration (Completed) |

# 1. Purpose

Define a repeatable, evidence-driven process for onboarding a SAML 2.0 enterprise application to Microsoft Entra ID, validating identity and authorization claims, troubleshooting federation failures, and preserving a known-good rollback path.

# 2. Scope

Use this SOP for SaaS or custom applications that use Microsoft Entra ID as the SAML Identity Provider (IdP). The Service Provider (SP) may be a production SaaS platform or an approved validation SP. This SOP covers discovery, trust configuration, assignment, NameID/claims, app roles, testing, Microsoft Graph verification, assertion inspection, cleanup, and handoff.

# 3. Core SAML Model

| **Component**           | **Meaning**                                                  | **APEX Reference**                                              |
|-------------------------|--------------------------------------------------------------|-----------------------------------------------------------------|
| Identity Provider (IdP) | Authenticates the user and issues the signed SAML assertion. | Microsoft Entra ID                                              |
| Service Provider (SP)   | Trusts the IdP assertion and provides the application.       | RouteSphere design / Microsoft Entra SAML Toolkit validation SP |
| Entity ID               | Uniquely identifies the SP/trust relationship.               | Vendor-provided SP Entity ID                                    |
| ACS / Reply URL         | Endpoint where Entra posts the SAML response.                | Vendor-provided ACS URL                                         |
| NameID                  | Primary identifier used by the SP to match the user.         | Corporate email when required by the SP                         |
| Claims                  | Identity/authorization attributes sent in the assertion.     | email, department, role                                         |

# 4. Roles and Responsibilities

- IAM Engineer: discovery, Entra configuration, testing, troubleshooting, evidence capture, rollback, and handoff.

- Application Owner: confirms business owner, pilot population, access model, application roles, cutover timing, and fallback path.

- Service Provider / Vendor: supplies Entity ID, ACS URL, sign-on URL or metadata, NameID format, required claims, signing requirements, and role semantics.

- Approver / Change Owner: approves production-facing trust, privileged role, cutover, and exception changes.

# 5. Required Inputs Before Configuration

- [ ] Business owner and technical/application owner identified.

- [ ] IdP and SP identified; protocol confirmed as SAML 2.0.

- [ ] Entity ID, ACS/Reply URL, optional Sign-on URL, and metadata obtained from the SP.

- [ ] NameID requirement confirmed (email, UPN, employee ID, immutable identifier, etc.).

- [ ] Required claims confirmed (for example first name, last name, email, department, role).

- [ ] Authorization model confirmed: assignment only, groups, app roles, or SP-managed roles.

- [ ] Pilot users/groups and negative-test user identified.

- [ ] JIT/provisioning behavior understood; SAML authentication is not the same as SCIM provisioning.

- [ ] Signing certificate requirements and rollover process documented.

- [ ] Rollback/fallback login method documented before cutover.

# 6. Implementation Procedure

## 6.1 Inspect Existing State

1.  Check whether an Enterprise Application already exists for the SP.

2.  Review existing users, groups, application assignments, app roles, claims, and certificates before creating duplicates.

3.  Capture screenshots or export configuration to establish the before-state.

## 6.2 Create or Select the Enterprise Application

4.  Use a gallery application when the vendor is supported; otherwise create a non-gallery enterprise application.

5.  Set Assignment required? = Yes when access should be limited to explicitly entitled users/groups.

6.  Prefer group-based entitlement for repeatable least-privilege access; avoid broad tenant-wide access unless the business requirement explicitly calls for it.

## 6.3 Build the Entitlement Model

7.  Create or validate the application access group (example: GRP-App-\<Application\>-Users).

8.  Add only approved pilot users. For the APEX reference implementation, Maya Brooks was the test identity.

9.  If the SP consumes business roles, define meaningful app-role values such as User, Dispatcher, Manager, or Admin. Do not assume the default msiam_access role provides a usable role claim.

## 6.4 Configure Basic SAML Trust

10. Enter the SP Entity ID exactly as supplied by the vendor.

11. Enter the SP ACS/Reply URL exactly. Treat endpoint mismatches as a federation failure condition.

12. Configure the Sign-on URL only when the SP provides/uses one.

13. Save the configuration and record the Entra IdP Login URL, Entra Identifier, logout URL, signing certificate, and federation metadata for the SP.

## 6.5 Configure NameID and Claims

14. Set NameID to the identifier the SP expects. Do not default to UPN without vendor confirmation.

15. For an email-based SP, use Name identifier format = Email address and source attribute = user.mail, provided that the attribute is populated.

16. Add only required claims. Example APEX mappings: department → user.department; role → user.assignedroles.

17. Validate source attributes on the test user before testing. A blank source attribute can cause matching or authorization failures.

## 6.6 Configure and Assign App Roles When Required

18. If the application consumes roles, define roles with a nonempty value. The value is the authorization string expected in the token/assertion.

19. Assign the user/group to the intended role through Enterprise applications → Users and groups, or through Microsoft Graph when the portal cannot perform the assignment.

20. Avoid assuming msiam_access is a business role. In the validated APEX case, Graph showed msiam_access.value = null, so no usable role value appeared in the SAML assertion.

## 6.7 Validate with a Real Service Provider

21. Use a real SP endpoint for end-to-end validation. A fictional hostname can validate design documentation but cannot consume a SAML response or create a genuine application sign-in event.

22. For the APEX reference implementation, Microsoft Entra SAML Toolkit was used as the validation SP.

23. Test in a fresh InPrivate/Incognito session to reduce session-reuse ambiguity.

24. Perform an SP-initiated login when supported: SP → Entra authentication → signed SAML response → SP ACS → application session.

25. Confirm the Enterprise Application sign-in log shows the expected user/application and Status = Success.

## 6.8 Detailed Click-by-Click SAML Integration Walkthrough

Use this walkthrough when onboarding a SAML 2.0 application to Microsoft Entra ID. The exact Entity ID, ACS URL, NameID format, claims, and certificate requirements must come from the Service Provider (SP) or vendor. Do not invent production endpoints.

### 6.8.1 Step 1 — Discovery and Change Preparation

- Identify the application business owner, technical owner, IAM owner, approver/change owner, and vendor contact.

- Confirm the protocol is SAML 2.0 and identify the IdP (Microsoft Entra ID) and the SP (the SaaS/custom application).

- Request or obtain the SP metadata and record: Entity ID, ACS/Reply URL, optional Sign-on URL, optional Logout URL, required NameID format, required claims, signing-certificate requirements, and whether the SP consumes application roles.

- Confirm whether accounts must already exist at the SP, whether JIT account creation is supported, and whether SCIM provisioning will be configured separately.

- Define the pilot population, negative-test user, fallback/local-login path, rollback plan, and test window before making the trust live.

**Decision gate:** Do not proceed until the SP requirements are known. SAML values should be vendor-provided or generated by a real test SP.

### 6.8.2 Step 2 — Validate the Test Identity and Entitlement Group

- Go to Entra ID → Users and open the pilot user. Confirm the account is enabled and the attributes required by the SAML design are populated.

- If the SP expects email as NameID, verify the user.mail value is populated with the corporate email address expected by the SP.

- Validate any required source attributes such as given name, surname, department, employee ID, or other vendor-required values.

- Go to Entra ID → Groups. Create or validate a Security group such as GRP-App-\<Application\>-Users with Assigned membership unless the approved design requires dynamic membership.

- Add only the approved pilot user(s) to the application group and capture the membership as before-state evidence.

**APEX reference:** Maya Brooks was used as the pilot identity; user.mail = maya.brooks@apexmobility.com and department = Security.

### 6.8.3 Step 3 — Create the Enterprise Application

- Open Microsoft Entra admin center → Entra ID → Enterprise applications → All applications → New application.

- If the vendor is available in the gallery, select the supported gallery application and follow the vendor-specific configuration guidance.

- For a custom/non-gallery application, select Create your own application, enter the application name, select “Integrate any other application you don’t find in the gallery (Non-gallery),” and create it.

- Open the new Enterprise Application → Properties. Set Enabled for users to sign-in? = Yes.

- Set Assignment required? = Yes when only explicitly entitled users/groups should be allowed to sign in, then Save.

**Least-privilege control:** Assignment required? = Yes prevents unassigned users from receiving access simply because they belong to the tenant.

### 6.8.4 Step 4 — Configure the Basic SAML Trust

- In the Enterprise Application, select Single sign-on → SAML.

- Under Basic SAML Configuration, select Edit.

- Enter Identifier (Entity ID) exactly as supplied by the SP. This identifies the SP/trust relationship.

- Enter Reply URL (Assertion Consumer Service URL) exactly as supplied by the SP. This is where Entra posts the SAML response.

- Enter the Sign-on URL only when the SP provides or requires one. Add Relay State or Logout URL only when required by the SP.

- Save the Basic SAML Configuration and verify the values persisted without truncation or typo.

| **Entra field**        | **What it means**                   | **Source**         |
|------------------------|-------------------------------------|--------------------|
| Identifier (Entity ID) | Who the SP is / the SAML audience   | SP metadata/vendor |
| Reply URL (ACS)        | Where Entra sends the SAML Response | SP metadata/vendor |
| Sign-on URL            | SP login/start URL when required    | SP/vendor          |
| Logout URL             | Optional logout endpoint            | SP/vendor          |

### 6.8.5 Step 5 — Configure NameID

- Under Attributes & Claims, open Unique User Identifier (Name ID).

- Set Name identifier format to the format required by the SP (for example Email address, Persistent, Unspecified).

- Set Source attribute to the Entra attribute that actually contains the identifier expected by the SP.

- For an email-matching application, use user.mail only after confirming it is populated and matches the SP-side account.

- Save the NameID configuration.

**Do not assume UPN = NameID.** The SP defines what identifier it expects; Entra maps an appropriate directory attribute to that requirement.

### 6.8.6 Step 6 — Configure Additional Claims

- Review the vendor-required attribute list and keep the assertion minimal: send only the claims the SP needs.

- Use Add new claim to create each required claim. Enter the exact claim name expected by the SP and choose the correct Source attribute.

- Typical mappings include given name → user.givenname, surname → user.surname, email → user.mail, and department → user.department.

- If the SP expects an application role in the assertion, add role → user.assignedroles after the role model is defined and assigned.

- Save each claim and re-open Attributes & Claims to verify the final mapping table.

| **Claim**    | **APEX mapping**   | **Purpose**                             |
|--------------|--------------------|-----------------------------------------|
| NameID       | user.mail          | SP account matching                     |
| emailaddress | user.mail          | Corporate email                         |
| department   | user.department    | Business context                        |
| role         | user.assignedroles | Application authorization when required |

### 6.8.7 Step 7 — Define Application Roles When the SP Uses Role-Based Authorization

- Confirm with the application owner/vendor whether the SP actually consumes a role value from the SAML assertion. If not, do not create unnecessary roles.

- When the application registration is controlled by your organization, go to Entra ID → App registrations → \<Application\> → App roles → Create app role.

- Enter a meaningful Display name, choose Users/Groups as the allowed member type, enter a nonempty Value, enter a description, keep the role enabled, and Apply.

- Examples for a business application may include User, Dispatcher, Manager, and Admin with matching nonempty values.

- If the application is a gallery/external enterprise application and the portal does not expose the required tenant-local role, inspect and manage the service principal appRoles through Microsoft Graph only after approval and after preserving existing role objects.

- Do not rely on msiam_access as a business role. A default role with value = null may permit assignment but does not provide a meaningful role value to emit in the SAML assertion.

**Important:** An app-registration client secret is not required merely to configure SAML SSO. Client secrets/certificates under App registrations are used for OAuth/OIDC/API scenarios when the application design requires them; the SAML signing certificate is managed under the Enterprise Application → Single sign-on page.

### 6.8.8 Step 8 — Provide Entra IdP Trust Values to the Service Provider

- Return to Enterprise Application → Single sign-on → SAML.

- Under SAML Certificates, confirm the token signing certificate is Active and record its expiration date and notification contact.

- Download the certificate format required by the SP (Base64 or Raw) and/or Federation Metadata XML.

- Under Set up \<Application\>, copy the Login URL, Microsoft Entra Identifier, and Logout URL when required.

- Configure those IdP values on the SP side and upload the Entra signing certificate as required by the SP.

- Save the SP configuration and capture the resulting SP-side configuration or metadata as evidence.

### 6.8.9 Step 9 — Assign the Pilot User/Group and Application Role

- Open Enterprise Application → Users and groups → Add user/group.

- Select the approved pilot user or, preferably, the approved application access group.

- If application roles exist, use Select a role and choose the approved role; otherwise use the application’s default assignment role.

- Select Assign and verify the user/group appears under Users and groups with the intended role.

- If the portal cannot perform a required role assignment, use Microsoft Graph only after verifying the user ID, service-principal resource ID, and appRole ID.

### 6.8.10 Step 10 — Perform the First End-to-End SSO Test

- Open a fresh InPrivate/Incognito browser to minimize cached sessions and stale claims.

- Start from the SP’s SP-initiated login URL when available. This tests the normal application-driven federation path.

- Authenticate as the approved pilot user through Microsoft Entra ID.

- Confirm Entra sends the SAML response to the configured ACS URL and the SP establishes an application session.

- Record the result as Success or Failure. If the application displays an authorization error, determine whether authentication completed before troubleshooting the role/claim layer.

### 6.8.11 Step 11 — Validate Entra Sign-In Evidence

- Open Enterprise Application → Sign-in logs.

- Filter to the pilot user and the target application, then open the matching interactive sign-in event.

- Verify Status, Authentication requirement, Conditional Access result, user, application, resource, timestamp, and request/correlation IDs as applicable.

- Capture successful sign-in evidence. If no Enterprise Application event exists, verify the browser actually redirected through Entra for this application before assuming an Entra configuration failure.

### 6.8.12 Step 12 — Inspect the Actual SAML Assertion

- Open browser Developer Tools → Network and enable Keep log / Preserve log.

- Repeat a fresh SP-initiated SAML login and locate the POST request to the ACS/Consume endpoint.

- Open Payload / Form Data and locate SAMLResponse.

- Copy the SAMLResponse value and decode it locally. Do not upload an unredacted assertion to public sites.

- Search the decoded XML for NameID and every required claim. Confirm the values match the directory and the approved role assignment.

// Browser console example for local Base64 decode  
const saml = 'PASTE_SAMLRESPONSE_HERE';  
console.log(atob(saml));

**Expected APEX evidence:** NameID/email = maya.brooks@apexmobility.com; department = Security; role = User.

### 6.8.13 Step 13 — Perform Authorization and Negative Tests

- Confirm the entitled pilot user can authenticate and reach the application.

- Use an unassigned/unauthorized test identity and confirm access is denied when Assignment required? = Yes.

- If roles are used, validate at least one role-specific positive case and confirm a user without that role does not receive the protected function.

- Document the expected and observed behavior for each test.

### 6.8.14 Step 14 — Troubleshoot by Layer, Not by Guessing

- No Entra sign-in event: confirm the SP initiated SAML and redirected to Entra; verify the endpoint is a real SP and not merely a fictional URL.

- Entra success but SP rejection: compare Entity ID/Audience, ACS Destination/Recipient, certificate trust, assertion timestamps, NameID, and required claims.

- One user fails: compare that user’s source attributes and SP account matching against a successful user.

- Role missing: inspect Attributes & Claims, then use Graph to verify appRoles.value and the user’s appRoleAssignments.

- If a default role such as msiam_access has value = null, create/assign an approved role with a nonempty value, retest, and prove the new role appears in the decoded assertion before cleanup.

### 6.8.15 Step 15 — Cleanup, Final Validation, and Handoff

- Remove temporary or redundant assignments only after the replacement state has been proven.

- Repeat the SSO test after cleanup and decode one final assertion to prove the expected NameID and claims still appear.

- Capture the final Enterprise Application assignment state, final sign-in event, final decoded-claim evidence, and any Graph verification used during troubleshooting.

- Document the rollback path, certificate expiration/owner, known-good Entity ID/ACS/NameID/claims, and operational support owner.

- Update the IAM ticket/tracker with implementation decisions, RCA/remediation, validation evidence, cleanup, residual risks, and next break/fix exercise.

### 6.8.16 Alternative Validation Path — Microsoft Entra SAML Toolkit (When the Business App Has No Real SP)

Use this path only as an approved validation harness. It does not turn a fictional application endpoint into a real SP; it supplies a genuine SAML consumer so the Entra transaction, claims, logs, and assertion can be validated end to end.

- Add Microsoft Entra SAML Toolkit from the Entra application gallery and enable SAML-based sign-on.

- Register the pilot user in the Toolkit using the email value that will be sent as NameID so the SP-side account can match the assertion.

- In the Toolkit, create the SAML configuration using the Entra Login URL, Microsoft Entra Identifier, Logout URL, and the Raw signing certificate from the Enterprise Application SAML page.

- The Toolkit returns a real SP Entity ID, ACS/Consume URL, and SP-initiated Login URL. Enter those SP values into Entra Basic SAML Configuration.

- Set NameID to Email address → user.mail for the Toolkit requirement; add the required department and role claims.

- Assign the pilot user to the Toolkit. If a meaningful role claim is required, verify the app role has a nonempty value and assign that role.

- Launch the Toolkit SP-initiated Login URL in InPrivate, authenticate through Entra, and confirm the Toolkit session is established.

- Validate the Microsoft Entra SAML Toolkit sign-in event in Entra and capture the SAMLResponse from the Toolkit ACS POST.

- Decode the assertion locally and verify NameID, department, role, and any other required attributes.

- Clean up redundant default/test assignments and perform one final SSO + assertion validation.

**APEX lesson learned:** RouteSphere was the business-design application, but its placeholder Entity ID/ACS URLs had no real SP behind them. Microsoft Entra SAML Toolkit supplied the real SP required to produce genuine sign-in logs and a consumable SAML assertion.

## 6.9 Visual Walkthrough — IAM-1055 Screenshots

The sanitized public evidence used for this walkthrough is maintained in [`tickets/IAM-1055-saml-sso-integration/evidence/`](../tickets/IAM-1055-saml-sso-integration/evidence/).

The screenshots below are the actual evidence captured during IAM-1055. Use them together with the numbered procedure in Section 6.8. They show the expected navigation, configuration, troubleshooting, and final validation states. Values shown are from the APEX learning environment and should not be copied into another tenant without validation.

**Evidence principle:** The screenshot proves the portal state; the sign-in log and decoded SAML assertion prove what actually occurred during authentication and what was transmitted to the Service Provider.


**Figure 1 — Create a non-gallery Enterprise Application** *(Step 3 — Create the Enterprise Application)*

**What to verify:** For a custom application, select Create your own application and choose the non-gallery integration option. The application name should match the onboarding record/change ticket.


**Figure 2 — Enforce explicit assignment for least-privilege access** *(Step 3 — Enterprise Application Properties)*

**What to verify:** Confirm Enabled for users to sign-in = Yes and Assignment required = Yes when only entitled users/groups should receive application access.


**Figure 3 — Configure the SAML trust values in Entra** *(Step 4 — Basic SAML Trust)*

**What to verify:** Verify the SP Entity ID, ACS/Reply URL, optional Sign-on URL, claims, signing certificate, and Entra IdP values. Entity ID identifies the SP; ACS is where Entra posts the SAML response.


**Figure 4 — Define meaningful application roles** *(Step 7 — Application Roles)*

**What to verify:** When the SP consumes application roles, use business-meaningful role names and nonempty values. The APEX RouteSphere design used User, Dispatcher, Manager, and Admin.


**Figure 5 — Assign the entitlement group to the application role** *(Step 9 — User/Group Assignment)*

**What to verify:** Prefer an approved application access group for repeatable least-privilege administration. Confirm the group is assigned to the intended application role, not simply added without role context when the SP requires roles.


**Figure 6 — Record Entra IdP trust values and signing certificate** *(Step 8 — IdP Trust Values)*

**What to verify:** Capture the active token-signing certificate, expiration, App Federation Metadata URL, Login URL, Microsoft Entra Identifier, and Logout URL required by the Service Provider.


**Figure 7 — Configure NameID and required claims** *(Steps 5–6 — NameID and Claims)*

**What to verify:** Verify NameID maps to the identifier expected by the SP and that only required claims are sent. For the Toolkit validation, NameID used user.mail; department was added as an application claim.


**Figure 8 — Validate the Enterprise Application sign-in event** *(Step 11 — Sign-In Evidence)*

**What to verify:** A successful Enterprise Application event confirms Entra processed the SAML authentication for the target application. Validate the user, application, status, time, and Conditional Access result.


**Figure 9 — Use Microsoft Graph to prove the role-claim root cause** *(Step 14 — Troubleshooting / RCA)*

**What to verify:** Graph showed the Toolkit default msiam_access app role had value = null. That explained why the role claim was absent even though Maya had an application assignment.


**Figure 10 — Final cleaned entitlement state** *(Step 15 — Cleanup and Handoff)*

**What to verify:** After remediation and cleanup, Maya Brooks appears once with Role assigned = User. The redundant msiam_access assignment was removed only after the replacement role was validated.


**Figure 11 — Final decoded SAML assertion proves the claims** *(Steps 12 & 15 — Assertion and Final Validation)*

**What to verify:** The final decoded assertion shows the expected identity/authorization data after cleanup, including department = Security and role = User. This is the strongest proof that the configured values were actually transmitted.

# 7. SAML Assertion Validation

A successful login proves the federation transaction worked, but it does not prove every expected claim was transmitted. Inspect the actual SAML response when validating NameID or authorization claims.

> 1\. Open browser Developer Tools → Network and enable Keep log / Preserve log.
>
> 2\. Perform a fresh SAML login and locate the POST to the SP ACS endpoint.
>
> 3\. Open Payload / Form Data and locate SAMLResponse.
>
> 4\. Decode the Base64 SAMLResponse locally. Do not post an unredacted assertion to public systems.
>
> 5\. Search the decoded XML for NameID and required claim names.

APEX final validated values:

NameID / emailaddress = maya.brooks@apexmobility.com  
department = Security  
role = User

# 8. Microsoft Graph Verification and Troubleshooting

Use Graph for read-only verification first. Move to POST/PATCH/DELETE only after the current state is known and the target object IDs are confirmed.

## 8.1 Inspect Service-Principal App Roles

az rest --method GET --url 'https://graph.microsoft.com/v1.0/servicePrincipals?\$filter=displayName%20eq%20%27\<Application%20Name\>%27&\$select=id,appId,displayName,appRoles'

Review displayName, value, id, isEnabled, and allowedMemberTypes. A role with value = null may satisfy assignment but will not provide a meaningful business-role value in the SAML assertion.

## 8.2 Inspect User App-Role Assignments

az rest --method GET --url 'https://graph.microsoft.com/v1.0/users/\<USER-ID\>/appRoleAssignments?\$select=id,appRoleId,resourceId,resourceDisplayName,principalDisplayName'

Match resourceId to the target service principal and appRoleId to the intended role. Preserve assignment IDs before cleanup or rollback.

## 8.3 Controlled Role Change Pattern

- Human review: confirm the application actually consumes roles and approve the intended business role.

- Automated execution: create/assign the approved app role and verify it with Graph.

- Validation: decode a new SAML assertion and confirm the expected role value appears.

- Cleanup: remove redundant test/default assignments only after the new role is proven.

# 9. Troubleshooting Decision Guide

| **Symptom**                                 | **Likely Layer**                                               | **First Checks**                                                                        |
|---------------------------------------------|----------------------------------------------------------------|-----------------------------------------------------------------------------------------|
| No Enterprise App sign-in event             | Request may never have reached Entra / SP endpoint is not real | Use a real SP; confirm SP-initiated redirect; inspect browser network flow.             |
| Entra authenticates but SP rejects response | Trust / Entity ID / ACS / signing certificate                  | Compare SP metadata, Destination/Recipient, Entity ID, certificate, and timestamps.     |
| Only one user fails                         | NameID / user attribute / account matching                     | Compare user.mail/UPN/NameID and SP-side account matching.                              |
| SSO succeeds but role is missing            | App role / claim mapping                                       | Check role claim mapping; inspect appRoles value and appRoleAssignments with Graph.     |
| Role exists but wrong value is received     | Role definition / multiple assignments                         | Verify appRoleId-to-value mapping; remove stale/redundant assignments after validation. |
| 403 at application URL but no Entra logs    | Application/web authorization or non-SAML endpoint             | Verify whether the URL is a real SP ACS/login endpoint before troubleshooting Entra.    |

# 10. Rollback and Cleanup

- [ ] Keep a known-good copy of Entity ID, ACS, NameID, claims, signing certificate, role definitions, and assignments before change.

- [ ] If a trust or claim change breaks SSO, revert only the changed item first and retest.

- [ ] If a new app role is introduced, validate it before removing the prior assignment.

- [ ] Remove redundant test/default assignments after successful validation.

- [ ] Confirm final Entra sign-in success and decode one final assertion after cleanup.

- [ ] Protect signing certificates, secrets, assertion captures, tenant IDs, and user identifiers according to internal handling requirements.

# 11. Evidence and Ticket Closure Checklist

- [ ] Customer requirement and business owner documented.

- [ ] IdP/SP and protocol documented.

- [ ] Entity ID / ACS / Sign-on values captured.

- [ ] Assignment model and pilot user/group captured.

- [ ] NameID and required claim mappings captured.

- [ ] Successful SP-initiated SSO evidence captured.

- [ ] Enterprise Application sign-in log shows Success.

- [ ] Decoded assertion verifies required identity/authorization claims.

- [ ] Any failure/RCA/remediation documented with before/after evidence.

- [ ] Cleanup/rollback verified and final state recorded.

- [ ] Next break/fix or operational task identified.

# 12. Automation Boundary

| **Automate / Assist**                                                                                                                                 | **Human Review / Approval**                                                                                                         | **Manual / High Risk**                                                                                                |
|-------------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------|
| Metadata/endpoint comparison; certificate inventory; assignment and role-state checks; sign-in-log collection; claim validation; evidence collection. | Protocol/trust design; NameID and claims; business-role semantics; entitlement approval; cutover; exceptions; remediation judgment. | Unapproved production trust changes; privileged role decisions; destructive cleanup without a verified rollback path. |

# 13. APEX IAM-1055 Reference Outcome

The IAM-1055 reference implementation established a known-good SAML baseline, then extended it to identity and authorization claims. RouteSphere remained the business-design application; Microsoft Entra SAML Toolkit supplied the real SP needed to validate the transaction.

- Group-based least-privilege design established for RouteSphere.

- Maya Brooks used as the scoped APEX test identity.

- Corporate email used as NameID for the email-matching SP requirement.

- Department claim validated as Security.

- Role claim initially absent; Graph RCA showed default msiam_access had value = null.

- Custom User app role created with value = User; assignment validated through Graph.

- Decoded SAML assertion proved role = User.

- Redundant msiam_access assignment removed; final SSO and claims validation remained successful.

# 14. Next Controlled Break/Fix Exercises

- IAM-1069 — signing-certificate rollover / stale SP trust.

- IAM-1070 — ACS / Entity ID mismatch.

- IAM-1071 — NameID / attribute-claim mapping failure.

Revision 1.1: Added a complete 15-step click-by-click SAML integration procedure, application-role workflow, real-SP validation path, assertion inspection, troubleshooting, cleanup, and final validation steps.

**End of SOP**
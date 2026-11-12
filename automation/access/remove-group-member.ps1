# APEX Mobility Group
# IAM Engineering - Mover Entitlement Revocation
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Remove obsolete access while preserving an approved required entitlement.

[CmdletBinding()]
param(
    [string]$UserPrincipalName = "avery.johnson@apexmobility.example",
    [string]$EntitlementGroup  = "GRP-Dept-Security",
    [string]$RequiredGroup     = "GRP-App-P2P-Users"
)

try {
    $User = Get-MgUser `
        -UserId $UserPrincipalName `
        -Property Id,DisplayName,UserPrincipalName,AccountEnabled `
        -ErrorAction Stop
}
catch {
    Write-Host "STOP: Target identity could not be retrieved."
    Write-Host $_.Exception.Message
    return
}

if (-not $User.AccountEnabled) {
    Write-Host "STOP: User account is disabled. This workflow is scoped as a mover access change."
    return
}

$Groups = @(
    Get-MgGroup `
        -Filter "displayName eq '$EntitlementGroup'" `
        -Property Id,DisplayName `
        -ErrorAction Stop
)

if ($Groups.Count -ne 1) {
    Write-Host "STOP: Expected exactly one entitlement group. Found: $($Groups.Count)"
    return
}

$TargetGroup = $Groups[0]

$UserGroups = Get-MgUserMemberOfAsGroup `
    -UserId $User.Id `
    -Property Id,DisplayName `
    -All `
    -ErrorAction Stop

$HasRequiredMembership    = @($UserGroups.DisplayName) -contains $RequiredGroup
$HasEntitlementMembership = @($UserGroups.Id) -contains $TargetGroup.Id

Write-Host ""
Write-Host "=== Access Impact Analysis ==="

if (-not $HasRequiredMembership) {
    Write-Host "STOP: Required access '$RequiredGroup' is not present. Do not continue."
    return
}

Write-Host "PRESERVE: $RequiredGroup"

if (-not $HasEntitlementMembership) {
    Write-Host "NO CHANGE: '$EntitlementGroup' is already absent."
    return
}

Write-Host "REMOVE: $EntitlementGroup"

$Approval = Read-Host "Type YES to remove the obsolete entitlement"
if ($Approval -ne "YES") {
    Write-Host "NO CHANGE: Mover access change cancelled."
    return
}

try {
    Remove-MgGroupMemberByRef `
        -GroupId $TargetGroup.Id `
        -DirectoryObjectId $User.Id `
        -ErrorAction Stop
}
catch {
    Write-Host "ERROR: Failed to remove group membership."
    Write-Host $_.Exception.Message
    return
}

$UpdatedGroups = Get-MgUserMemberOfAsGroup `
    -UserId $User.Id `
    -Property Id,DisplayName `
    -All `
    -ErrorAction Stop

$RequiredStillPresent  = @($UpdatedGroups.DisplayName) -contains $RequiredGroup
$EntitlementStillThere = @($UpdatedGroups.Id) -contains $TargetGroup.Id

if ($RequiredStillPresent -and -not $EntitlementStillThere) {
    Write-Host "VALIDATED: Mover access change completed successfully."
    Write-Host "PRESERVED: $RequiredGroup"
    Write-Host "REMOVED:   $EntitlementGroup"
}
else {
    Write-Host "VALIDATION FAILED: Final access state does not match the approved request."
}
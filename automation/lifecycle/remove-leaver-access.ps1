# APEX Mobility Group
# IAM Engineering - Leaver Access Revocation
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Remove only approved workforce/application access from a disabled leaver identity.

[CmdletBinding()]
param(
    [string]$UserPrincipalName = "avery.johnson@apexmobility.example",
    [string[]]$GroupsToRemove = @(
        "GRP-App-P2P-Users",
        "GRP-Dept-Security"
    )
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

Write-Host ""
Write-Host "=== Target Identity ==="
Write-Host "Name:            $($User.DisplayName)"
Write-Host "UPN:             $($User.UserPrincipalName)"
Write-Host "Account Enabled: $($User.AccountEnabled)"

# Safety gate: access removal must not continue while the leaver account is enabled.
if ($User.AccountEnabled -eq $true) {
    Write-Host ""
    Write-Host "STOP: Leaver account is still enabled."
    return
}

Write-Host ""
Write-Host "PASS: Leaver account is disabled."

$ValidatedGroups = @()

foreach ($GroupName in $GroupsToRemove) {
    $Groups = @(
        Get-MgGroup `
            -Filter "displayName eq '$GroupName'" `
            -Property Id,DisplayName `
            -ErrorAction Stop
    )

    if ($Groups.Count -ne 1) {
        Write-Host "STOP: Expected exactly one approved group named '$GroupName'. Found: $($Groups.Count)"
        return
    }

    $ValidatedGroups += $Groups[0]
}

$CurrentGroups = Get-MgUserMemberOfAsGroup `
    -UserId $User.Id `
    -Property Id,DisplayName `
    -All `
    -ErrorAction Stop

Write-Host ""
Write-Host "=== Approved Leaver Access Removal ==="

foreach ($Group in $ValidatedGroups) {
    $ExistingMembership = $CurrentGroups | Where-Object { $_.Id -eq $Group.Id }

    if ($ExistingMembership) {
        Write-Host "REMOVE: $($Group.DisplayName)"
    }
    else {
        Write-Host "NO CHANGE: $($Group.DisplayName) is already absent."
    }
}

$Approval = Read-Host "Type YES to remove the approved leaver access"
if ($Approval -ne "YES") {
    Write-Host "NO CHANGE: Leaver access removal cancelled."
    return
}

foreach ($Group in $ValidatedGroups) {
    $ExistingMembership = $CurrentGroups | Where-Object { $_.Id -eq $Group.Id }

    if ($ExistingMembership) {
        try {
            Remove-MgGroupMemberByRef `
                -GroupId $Group.Id `
                -DirectoryObjectId $User.Id `
                -ErrorAction Stop

            Write-Host "REMOVED: $($Group.DisplayName)"
        }
        catch {
            Write-Host "ERROR: Failed to remove $($Group.DisplayName)"
            Write-Host $_.Exception.Message
            return
        }
    }
}

$UpdatedGroups = Get-MgUserMemberOfAsGroup `
    -UserId $User.Id `
    -Property Id,DisplayName `
    -All `
    -ErrorAction Stop

$RemainingLeaverGroups = @(
    foreach ($TargetGroup in $ValidatedGroups) {
        if ($UpdatedGroups | Where-Object { $_.Id -eq $TargetGroup.Id }) {
            $TargetGroup
        }
    }
)

Write-Host ""
Write-Host "=== Post-Change Validation ==="

if ($RemainingLeaverGroups.Count -eq 0) {
    Write-Host "VALIDATED: Approved leaver group access has been removed."
}
else {
    Write-Host "WARNING: Residual approved leaver access still exists."
    foreach ($RemainingGroup in $RemainingLeaverGroups) {
        Write-Host "RESIDUAL: $($RemainingGroup.DisplayName)"
    }
}
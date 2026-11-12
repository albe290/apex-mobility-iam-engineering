# APEX Mobility Group
# IAM Automation - Add Group Member
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Add an approved user to an approved Entra ID group with idempotency and validation.

[CmdletBinding()]
param(
    [string]$UserName  = "Priya Shah",
    [string]$GroupName = "GRP-Dept-Finance"
)

try {
    $Users = @(
        Get-MgUser `
            -Filter "displayName eq '$UserName'" `
            -Property Id,DisplayName,UserPrincipalName `
            -ErrorAction Stop
    )

    $Groups = @(
        Get-MgGroup `
            -Filter "displayName eq '$GroupName'" `
            -Property Id,DisplayName `
            -ErrorAction Stop
    )
}
catch {
    Write-Host "ERROR: Unable to resolve the requested user or group."
    Write-Host $_.Exception.Message
    return
}

if ($Users.Count -ne 1) {
    Write-Host "STOP: Expected exactly one user named '$UserName'. Found: $($Users.Count)"
    return
}

if ($Groups.Count -ne 1) {
    Write-Host "STOP: Expected exactly one group named '$GroupName'. Found: $($Groups.Count)"
    return
}

$User  = $Users[0]
$Group = $Groups[0]

$Members = Get-MgGroupMember `
    -GroupId $Group.Id `
    -All `
    -ErrorAction Stop

$ExistingMember = $Members | Where-Object { $_.Id -eq $User.Id }

if ($ExistingMember) {
    Write-Host "NO CHANGE: $($User.DisplayName) is already a member of $($Group.DisplayName)."
    return
}

Write-Host "Planned change: $($User.DisplayName) -> $($Group.DisplayName)"
$Approval = Read-Host "Type YES to add the user to this group"

if ($Approval -ne "YES") {
    Write-Host "NO CHANGE: Group assignment cancelled."
    return
}

try {
    New-MgGroupMemberByRef `
        -GroupId $Group.Id `
        -OdataId "https://graph.microsoft.com/v1.0/directoryObjects/$($User.Id)" `
        -ErrorAction Stop
}
catch {
    Write-Host "ERROR: Failed to add group membership."
    Write-Host $_.Exception.Message
    return
}

$UpdatedMembers = Get-MgGroupMember `
    -GroupId $Group.Id `
    -All `
    -ErrorAction Stop

$AddedMember = $UpdatedMembers | Where-Object { $_.Id -eq $User.Id }

if ($AddedMember) {
    Write-Host "VALIDATED: $($User.DisplayName) is now a member of $($Group.DisplayName)."
}
else {
    Write-Host "VALIDATION FAILED: Membership was not found after the update."
}
# APEX Mobility Group
# IAM Automation - Application Entitlement Validation
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Validate the chain User -> Entitlement Group -> Enterprise Application.

[CmdletBinding()]
param(
    [string]$UserName  = "Taylor Morgan",
    [string]$GroupName = "GRP-App-P2P-Users",
    [string]$AppName   = "P2P Server"
)

try {
    $Users = @(
        Get-MgUser `
            -Filter "displayName eq '$UserName'" `
            -Property Id,DisplayName `
            -ErrorAction Stop
    )

    $Groups = @(
        Get-MgGroup `
            -Filter "displayName eq '$GroupName'" `
            -Property Id,DisplayName `
            -ErrorAction Stop
    )

    $Apps = @(
        Get-MgServicePrincipal `
            -Filter "displayName eq '$AppName'" `
            -Property Id,DisplayName,AppId `
            -ErrorAction Stop
    )
}
catch {
    Write-Host "ERROR: Unable to resolve the user, group, or enterprise application."
    Write-Host $_.Exception.Message
    return
}

if ($Users.Count -ne 1 -or $Groups.Count -ne 1 -or $Apps.Count -ne 1) {
    Write-Host "STOP: User, group, and application names must each resolve to exactly one object."
    return
}

$User  = $Users[0]
$Group = $Groups[0]
$App   = $Apps[0]

$UserGroups = Get-MgUserMemberOfAsGroup `
    -UserId $User.Id `
    -Property Id,DisplayName `
    -All `
    -ErrorAction Stop

$UserInGroup = $UserGroups | Where-Object { $_.Id -eq $Group.Id }

$AppAssignments = Get-MgServicePrincipalAppRoleAssignedTo `
    -ServicePrincipalId $App.Id `
    -All `
    -ErrorAction Stop

$GroupAssignedToApp = $AppAssignments | Where-Object { $_.PrincipalId -eq $Group.Id }

if ($UserInGroup -and $GroupAssignedToApp) {
    Write-Host "VALIDATED: Application entitlement chain is complete."
    Write-Host "$($User.DisplayName) -> $($Group.DisplayName) -> $($App.DisplayName)"
}
else {
    Write-Host "VALIDATION FAILED: Application entitlement chain is incomplete."
    Write-Host "User in entitlement group: $([bool]$UserInGroup)"
    Write-Host "Group assigned to application: $([bool]$GroupAssignedToApp)"
}
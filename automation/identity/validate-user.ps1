# APEX Mobility Group
# IAM Automation - User and Group Validation
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Read-only validation of an Entra ID user and direct/transitive group access.

[CmdletBinding()]
param(
    [string]$UserName = "Sarah Mitchell"
)

try {
    $Users = @(
        Get-MgUser `
            -Filter "displayName eq '$UserName'" `
            -Property Id,DisplayName,UserPrincipalName,AccountEnabled,Department,JobTitle,EmployeeId `
            -ErrorAction Stop
    )
}
catch {
    Write-Host "ERROR: Unable to retrieve user."
    Write-Host $_.Exception.Message
    return
}

if ($Users.Count -ne 1) {
    Write-Host "STOP: Expected exactly one user named '$UserName'. Found: $($Users.Count)"
    return
}

$User = $Users[0]

try {
    $Groups = Get-MgUserMemberOfAsGroup `
        -UserId $User.Id `
        -Property Id,DisplayName `
        -All `
        -ErrorAction Stop
}
catch {
    Write-Host "ERROR: Unable to retrieve group memberships."
    Write-Host $_.Exception.Message
    return
}

Write-Host ""
Write-Host "=== Identity ==="

$User |
    Select-Object `
        DisplayName,
        UserPrincipalName,
        AccountEnabled,
        Department,
        JobTitle,
        EmployeeId

Write-Host ""
Write-Host "=== Group Membership ==="

$Groups |
    Select-Object DisplayName,Id |
    Sort-Object DisplayName
# APEX Mobility Group
# IAM Automation - Group Membership Inspection
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Read-only validation of an Entra ID user's group memberships.

[CmdletBinding()]
param(
    [string]$UserName = "Avery Johnson"
)

try {
    $Users = @(
        Get-MgUser `
            -Filter "displayName eq '$UserName'" `
            -Property Id,DisplayName `
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

Write-Host "User: $($User.DisplayName)"

$Groups |
    Select-Object DisplayName,Id |
    Sort-Object DisplayName
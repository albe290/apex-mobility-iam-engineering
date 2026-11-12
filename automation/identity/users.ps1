# APEX Mobility Group
# IAM Automation - Identity Inspection
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Read-only validation of an Entra ID user.

[CmdletBinding()]
param(
    [string]$UserName = "Avery Johnson"
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

$User |
    Select-Object `
        DisplayName,
        UserPrincipalName,
        AccountEnabled,
        Department,
        JobTitle,
        EmployeeId
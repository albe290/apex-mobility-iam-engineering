# APEX Mobility Group
# IAM Automation - Disable User
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Disable an approved Entra ID account only when it is currently enabled.

[CmdletBinding()]
param(
    [string]$UserName = "Avery Johnson"
)

try {
    $Users = @(
        Get-MgUser `
            -Filter "displayName eq '$UserName'" `
            -Property Id,DisplayName,UserPrincipalName,AccountEnabled `
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

Write-Host "User: $($User.DisplayName)"
Write-Host "Current Account State: $($User.AccountEnabled)"

if ($User.AccountEnabled -eq $false) {
    Write-Host "NO CHANGE: Account is already disabled."
    return
}

$Approval = Read-Host "Type YES to disable this account"
if ($Approval -ne "YES") {
    Write-Host "NO CHANGE: Disable operation cancelled."
    return
}

try {
    Update-MgUser `
        -UserId $User.Id `
        -AccountEnabled $false `
        -ErrorAction Stop
}
catch {
    Write-Host "ERROR: Account disable operation failed."
    Write-Host $_.Exception.Message
    return
}

$UpdatedUser = Get-MgUser `
    -UserId $User.Id `
    -Property Id,DisplayName,UserPrincipalName,AccountEnabled `
    -ErrorAction Stop

if ($UpdatedUser.AccountEnabled -eq $false) {
    Write-Host "VALIDATED: Account is disabled."
}
else {
    Write-Host "VALIDATION FAILED: AccountEnabled is not false."
}

$UpdatedUser |
    Select-Object DisplayName,UserPrincipalName,AccountEnabled
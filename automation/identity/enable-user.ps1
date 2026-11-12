# APEX Mobility Group
# IAM Automation - Enable User
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Enable an approved Entra ID account only when it is currently disabled.

[CmdletBinding()]
param(
    [string]$UserName = "Taylor Morgan"
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

if ($User.AccountEnabled -eq $true) {
    Write-Host "NO CHANGE: Account is already enabled."
    return
}

$Approval = Read-Host "Type YES to enable this account"
if ($Approval -ne "YES") {
    Write-Host "NO CHANGE: Enable operation cancelled."
    return
}

try {
    Update-MgUser `
        -UserId $User.Id `
        -AccountEnabled $true `
        -ErrorAction Stop
}
catch {
    Write-Host "ERROR: Account enable operation failed."
    Write-Host $_.Exception.Message
    return
}

$UpdatedUser = Get-MgUser `
    -UserId $User.Id `
    -Property Id,DisplayName,UserPrincipalName,AccountEnabled `
    -ErrorAction Stop

if ($UpdatedUser.AccountEnabled -eq $true) {
    Write-Host "VALIDATED: Account is enabled."
}
else {
    Write-Host "VALIDATION FAILED: AccountEnabled is not true."
}

$UpdatedUser |
    Select-Object DisplayName,UserPrincipalName,AccountEnabled
# APEX Mobility Group
# IAM Automation - Sign-In Validation
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Inspect recent Entra sign-in events for an application and surface the latest result.

[CmdletBinding()]
param(
    [string]$UserName = "Taylor Morgan",
    [string]$AppName  = "P2P Server"
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
    $SignIns = Get-MgAuditLogSignIn `
        -Filter "userId eq '$($User.Id)'" `
        -Sort "CreatedDateTime desc" `
        -Top 50 `
        -ErrorAction Stop
}
catch {
    Write-Host "ERROR: Unable to retrieve sign-in logs."
    Write-Host $_.Exception.Message
    return
}

$AppSignIns = @(
    $SignIns |
        Where-Object { $_.AppDisplayName -eq $AppName } |
        Sort-Object CreatedDateTime -Descending
)

if ($AppSignIns.Count -eq 0) {
    Write-Host "NO DATA: No recent '$AppName' sign-ins were found for $($User.DisplayName)."
    return
}

$LatestSignIn = $AppSignIns[0]

Write-Host ""
Write-Host "=== Latest Application Sign-In ==="

$LatestSignIn |
    Select-Object `
        CreatedDateTime,
        AppDisplayName,
        ConditionalAccessStatus,
        @{Name="ErrorCode";Expression={$_.Status.ErrorCode}},
        @{Name="FailureReason";Expression={$_.Status.FailureReason}}

Write-Host ""

if ($LatestSignIn.Status.ErrorCode -eq 0) {
    Write-Host "RESULT: Sign-in successful."
}
elseif ($LatestSignIn.Status.ErrorCode -eq 50105) {
    Write-Host "RESULT: ACCESS DENIED."
    Write-Host "Reason: User is not assigned to the application."
}
else {
    Write-Host "RESULT: Sign-in failed."
    Write-Host "Error Code: $($LatestSignIn.Status.ErrorCode)"
    Write-Host "Reason: $($LatestSignIn.Status.FailureReason)"
}

Write-Host ""
Write-Host "=== Retrieved Application Events ==="

$AppSignIns |
    Select-Object `
        CreatedDateTime,
        AppDisplayName,
        ConditionalAccessStatus,
        @{Name="ErrorCode";Expression={$_.Status.ErrorCode}},
        @{Name="FailureReason";Expression={$_.Status.FailureReason}} |
    Format-Table -AutoSize
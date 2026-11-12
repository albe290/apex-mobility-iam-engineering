# APEX Mobility Group
# IAM Engineering - Mover Identity Update
# Public portfolio copy: sanitized and hardened from the recovered lab script.
# Purpose: Update approved identity attributes and manager relationship for an employee transfer.

[CmdletBinding()]
param(
    [string]$UserPrincipalName = "priya.shah@apexmobility.example",
    [string]$NewManagerUPN     = "marcus.reed@apexmobility.example",
    [string]$NewJobTitle       = "Finance Operations Manager",
    [string]$NewDepartment     = "Finance"
)

try {
    $User = Get-MgUser `
        -UserId $UserPrincipalName `
        -Property Id,DisplayName,UserPrincipalName,JobTitle,Department,EmployeeId,AccountEnabled `
        -ErrorAction Stop

    $NewManager = Get-MgUser `
        -UserId $NewManagerUPN `
        -Property Id,DisplayName,UserPrincipalName,AccountEnabled `
        -ErrorAction Stop
}
catch {
    Write-Host "STOP: Target user or manager could not be retrieved."
    Write-Host $_.Exception.Message
    return
}

if (-not $NewManager.AccountEnabled) {
    Write-Host "STOP: Target manager account is disabled."
    return
}

$OriginalEmployeeId     = $User.EmployeeId
$OriginalAccountEnabled = $User.AccountEnabled

try {
    $CurrentManagerRef = Get-MgUserManager -UserId $User.Id -ErrorAction Stop
    $CurrentManager = Get-MgUser `
        -UserId $CurrentManagerRef.Id `
        -Property Id,DisplayName,UserPrincipalName `
        -ErrorAction Stop
}
catch {
    Write-Host "STOP: Current manager relationship could not be validated."
    Write-Host $_.Exception.Message
    return
}

Write-Host ""
Write-Host "=== Current Identity State ==="
Write-Host "Name:        $($User.DisplayName)"
Write-Host "Job Title:   $($User.JobTitle)"
Write-Host "Department:  $($User.Department)"
Write-Host "Employee ID: $($User.EmployeeId)"
Write-Host "Manager:     $($CurrentManager.DisplayName)"
Write-Host "Enabled:     $($User.AccountEnabled)"

Write-Host ""
Write-Host "=== Approved Mover State ==="
Write-Host "Job Title:   $NewJobTitle"
Write-Host "Department:  $NewDepartment"
Write-Host "Manager:     $($NewManager.DisplayName)"

$Approval = Read-Host "Type YES to apply the mover change"
if ($Approval -ne "YES") {
    Write-Host "NO CHANGE: Mover request cancelled."
    return
}

try {
    Update-MgUser `
        -UserId $User.Id `
        -JobTitle $NewJobTitle `
        -Department $NewDepartment `
        -ErrorAction Stop

    $ManagerReference = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/users/$($NewManager.Id)"
    }

    Set-MgUserManagerByRef `
        -UserId $User.Id `
        -BodyParameter $ManagerReference `
        -ErrorAction Stop
}
catch {
    Write-Host "ERROR: Mover update failed."
    Write-Host $_.Exception.Message
    return
}

$UpdatedUser = Get-MgUser `
    -UserId $User.Id `
    -Property Id,DisplayName,UserPrincipalName,JobTitle,Department,EmployeeId,AccountEnabled `
    -ErrorAction Stop

$UpdatedManagerRef = Get-MgUserManager `
    -UserId $User.Id `
    -ErrorAction Stop

$UpdatedManager = Get-MgUser `
    -UserId $UpdatedManagerRef.Id `
    -Property Id,DisplayName `
    -ErrorAction Stop

Write-Host ""
Write-Host "=== Post-Change Validation ==="
Write-Host "Name:        $($UpdatedUser.DisplayName)"
Write-Host "Job Title:   $($UpdatedUser.JobTitle)"
Write-Host "Department:  $($UpdatedUser.Department)"
Write-Host "Employee ID: $($UpdatedUser.EmployeeId)"
Write-Host "Manager:     $($UpdatedManager.DisplayName)"
Write-Host "Enabled:     $($UpdatedUser.AccountEnabled)"

if (
    $UpdatedUser.JobTitle -eq $NewJobTitle -and
    $UpdatedUser.Department -eq $NewDepartment -and
    $UpdatedManager.Id -eq $NewManager.Id -and
    $UpdatedUser.EmployeeId -eq $OriginalEmployeeId -and
    $UpdatedUser.AccountEnabled -eq $OriginalAccountEnabled
) {
    Write-Host "VALIDATED: Mover identity update completed successfully."
}
else {
    Write-Host "VALIDATION FAILED: Final state does not fully match the approved mover request."
}
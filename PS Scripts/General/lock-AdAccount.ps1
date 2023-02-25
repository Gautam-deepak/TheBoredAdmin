$AccountLockoutThreshold = ((([xml](Get-GPOReport -Name "Default Domain Policy" -ReportType Xml)).GPO.Computer.ExtensionData.Extension.Account |
            Where-Object name -eq LockoutBadCount).SettingNumber)

if (!$AccountLockoutThreshold) { Write-Output "Account Lockout Threshold is Not Defined in Default Domain Policy"; return; }

Write-Output "Account will lock out after '$AccountLockoutThreshold' invalid login attempts"

$username = "howardsimpson"

$password = ConvertTo-SecureString 'incorrect password' -AsPlainText -Force

$credential = New-Object System.Management.Automation.PSCredential ($username, $password)   

$attempts = 0

Do {                         

    $attempts++

    Write-Output "'$username' login attempt $attempts"

    Enter-PSSession -ComputerName 2K19-DC -Credential $credential -ErrorAction SilentlyContinue           

}

Until ($attempts -eq $AccountLockoutThreshold)

Write-Output "'$username' successfully locked out." 

# Import Module Psexcel which enables converting csv files to excel files

Import-Module "C:\Program Files\WindowsPowerShell\Modules\PSExcel\1.0.2\PSExcel.psm1"

# Import-module Powershell Archive which enables compressing the files

Import-Module "C:\Program Files\WindowsPowerShell\Modules\Microsoft.PowerShell.Archive\1.2.5\Microsoft.PowerShell.Archive.psm1"

# variables

$ErrorActionPreference="stop"
$PCName = $env:COMPUTERNAME
$date=(Get-Date).GetDateTimeFormats()[6]
$domain=$env:USERDOMAIN
$server="servers_$date"
$client="clients_$date"
$serverfile="$($domain)_$($server)"
$clientfile="$($domain)_$($client)"
$report="$($domain)_AD_Dump_$($date)"
$scriptpath="C:\script"
$EmailBody = "Hello All,`n`nPlease find the attached AD Dump for $domain dated $date.`n`nRegards `nDeepak "
$EmailFrom = ""
[string[]]$EmailTo = ""
[string[]]$EmailCC = ""
$EmailSubject = "$report"
$SMTPServer = "smtp.office365.com"

# To generate a AES key for encryption (Need to be used only once,must be removed from the script)
#$aeskeypath = "$scriptpath\aeskey.key"
#$AESKey = New-Object Byte[] 32
#[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
#Set-Content $aeskeypath $AESKey 

# Retrieve all windows Server computer
Get-ADComputer -Filter * -Properties * | Where-Object {$_.operatingsystem -match "server"} | `
Select-Object -Property Name, canonicalName, Enabled, DNSHostName, IPv4Address, LastlogonDate, Passwordlastset, Operatingsystem, Whenchanged, whencreated | `
export-csv -path $scriptpath\test.csv -Force 
$import=Get-Content -Path $scriptpath\test.csv
$import | Select-Object -Skip 1 | Set-Content $scriptpath\servers.csv
Import-Csv $scriptpath\servers.csv | Export-XLSX $scriptpath\$serverfile.xlsx -force
Remove-Item -Path $scriptpath\test.csv,$scriptpath\servers.csv -ErrorAction SilentlyContinue


# Retrieve all windows client computer

Get-ADComputer -Filter * -Properties * | Where-Object {$_.operatingsystem -notmatch "server"} | `
Select-Object -Property Name, canonicalName, Enabled, DNSHostName, IPv4Address, LastlogonDate, Passwordlastset, Operatingsystem, Whenchanged,whencreated | `
export-csv -path $scriptpath\test1.csv -force
$import=Get-Content -Path $scriptpath\test1.csv
$import | Select-Object -Skip 1 | Set-Content $scriptpath\clients.csv
Import-Csv $scriptpath\clients.csv | Export-XLSX $scriptpath\$clientfile.xlsx -force
Remove-Item -Path $scriptpath\test1.csv,C:\script\clients.csv -ErrorAction SilentlyContinue


# To write password into a password file using a secure AES key (Need to be used only once,must be removed from the script)

#(get-credential).password | ConvertFrom-SecureString -Key (Get-Content $scriptpath\aeskey.key) | set-content $scriptpath\password.txt

# Using the encrypted password again in the script

$encrypted=Get-Content $scriptpath\password.txt | ConvertTo-SecureString -Key (Get-Content $scriptpath\aeskey.key)

# Using the saved password and username in the credential

$credential = New-Object System.Management.Automation.PSCredential($EmailFrom,$encrypted)

# Compress two files in a zip

Compress-Archive -Path "$scriptpath\$clientfile.xlsx","$scriptpath\$serverfile.xlsx" -DestinationPath "$scriptpath\$report.zip"

# Sending Email using Send-MailMessage with attachments

[Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12

Send-MailMessage -From $EmailFrom -To $EmailTo -Cc $EmailCC -Subject $EmailSubject -body $EmailBody -SmtpServer $SMTPServer  -Credential $credential -UseSsl -Attachments $scriptpath\$report.zip -DeliveryNotificationOption OnFailure

# Removing the unwanted files

Remove-Item -Path $scriptpath\$serverfile.xlsx, $scriptpath\$clientfile.xlsx -ErrorAction SilentlyContinue








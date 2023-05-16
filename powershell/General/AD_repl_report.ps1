## Active Directory: PowerShell Script to check the Status of AD Replication across a Forest. Includes HTML report and Email Functionality ##

<#
Overview:
This script uses the output of the repadmin command (repadmin /showrepl) to check the AD replication on all the domain controllers and naming contexts all over an Active Directory forest.
 
If errors are found, a csv report is sent by email. 

#>

#Variables
$ADreport_path = "C:\script\reports"
$scriptpath="c:\script"
$date=(Get-Date).GetDateTimeFormats()[6]
$AD_report_name="AD_Repl_Report_$date"
$domain=$env:userdomain
$EmailBody = "Hello All,`n`nPlease find the attached AD Replication Report for $domain dated $date.`n`nRegards `nDeepak Gautam"
$EmailFrom = ""
[string[]]$EmailTo = ""
[string[]]$EmailCC = ""
$EmailSubject = $AD_report_name
$SMTPServer = "smtp.office365.com"
$LogFolder = "C:\script\logs"
$LogFile = $LogFolder + "\" + (Get-Date -UFormat "%d-%m-%Y") + ".log"
$ErrorActionPreference="silentlycontinue"

 
#Powershell Function to delete files older than a certain age
$FileAged = 8  #age of files in days

 
#create filter to exclude folders and files newer than specified age
Filter remove-agedFiles {
param($days)
If ($_.PSisContainer) {}
# Exclude folders from result set
ElseIf ($_.LastWriteTime -lt (Get-Date).AddDays($days * -1))
{$_}
}
 
# Function to log any errors

Function Write-Log
{
	param (
        [Parameter(Mandatory=$True)]
        [array]$LogOutput
	)
	$currentDate = (Get-Date -UFormat "%d-%m-%Y")
	$currentTime = (Get-Date -UFormat "%T")
	$logOutput = $logOutput -join (" ")
	"[$currentDate $currentTime] $logOutput" | Out-File $LogFile -Append
}

# Main

$DCs = Get-ADDomainController -Filter * |Sort-Object name
$results = @()

ForEach ($DC in $DCs) {
    
    Write-Log "Getting replication metadata for $($DC.HostName)"
    
    $ReplStatuses = Get-ADReplicationPartnerMetadata -target $DC.HostName -PartnerType Both -ErrorAction SilentlyContinue 
    
    If ($ReplStatuses) {

        Write-Log "$($ReplStatuses.Count) replication links found for $($DC.HostName)"

        ForEach ($ReplStatus in $ReplStatuses) {
            
            $Partner = $ReplStatus.Partner.Split(",")[1].Replace("CN=","")

            $results += [pscustomobject] @{
                'Source DC' = $DC.HostName.ToUpper()
                'Partner DC' = (Get-ADComputer $Partner).DNSHostName.ToUpper()
                Direction = $ReplStatus.PartnerType
                Type = $ReplStatus.IntersiteTransportType
                'Last Attempt' = $ReplStatus.LastReplicationAttempt
                'Last Success' = $ReplStatus.LastReplicationSuccess
                'Last Result' = $ReplStatus.LastReplicationResult
                }
        }
    } Else {
        Write-Log "Unable to get replication status for $($DC.HostName)"
        $results += [pscustomobject] @{
            'Source DC' = $DC.HostName.ToUpper()
            'Partner DC' = "N/A"
            Direction = "N/A"
            Type = "N/A"
            'Last Attempt' = "N/A"
            'Last Success' = "N/A"
            'Last Result' = "N/A"
            }
    }
}

# To generate a AES key for encryption (Need to be used only once,must be removed from the script)
#$aeskeypath = "$scriptpath\aeskey.key"
#$AESKey = New-Object Byte[] 32
#[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
#Set-Content $aeskeypath $AESKey 

# To write password into a password file using a secure AES key (Need to be used only once,must be removed from the script)

#(get-credential).password | ConvertFrom-SecureString -Key (Get-Content $scriptpath\aeskey.key) | set-content $scriptpath\password.txt

# Using the encrypted password again in the script

$encrypted=Get-Content $scriptpath\password.txt | ConvertTo-SecureString -Key (Get-Content $scriptpath\aeskey.key)

# Using the saved password and username in the credential

$credential = New-Object System.Management.Automation.PSCredential($EmailFrom,$encrypted)


$results | Export-Csv -Path $ADreport_path\$AD_report_name.csv -NoTypeInformation -Force

[Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12

Write-Log "Results published in the log files for $date"

get-Childitem -recurse $ADreport_path | remove-agedFiles $intFileAge 'CreationTime' | Remove-Item

Write-log   "Items from age $FileAged deleted"

Send-MailMessage -From $EmailFrom -To $EmailTo -Cc $EmailCC -Subject $EmailSubject -body $EmailBody -SmtpServer $SMTPServer  -Credential $credential -UseSsl -Attachments $ADreport_path\$AD_report_name.csv -DeliveryNotificationOption OnFailure

write-log "Email sent"


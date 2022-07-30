
###############################################################################################################################
#   Author :- Deepak Gautam                                                                                                   #
#   Email :- deepakgautam139@gmail.com                                                                                            #
#   Date :- 25-June-2021                                                                                                      #
#   Description :- Script is to collect mailbox usage report and send it as an email attachment                               #
###############################################################################################################################

<# To generate a AES key for encryption (Need to be used only once,must be removed/commented from the script)
$aeskeypath = "$scriptpath\aeskey.key"
$AESKey = New-Object Byte[] 32
[Security.Cryptography.RNGCryptoServiceProvider]::Create().GetBytes($AESKey)
Set-Content $aeskeypath $AESKey 

 To write password into a password file using a secure AES key (Need to be used only once,must be removed/commented from the script)

(get-credential).password | ConvertFrom-SecureString -Key (Get-Content $scriptpath\aeskey.key) | set-content $scriptpath\password.txt

#>

# Variables

$Emailreport_path = "C:\script\reports"
$scriptpath="c:\script"
$date=(Get-Date).GetDateTimeFormats()[6]
$EMail_report_name="Mailbox_Usage_Report_$date"
$domain="UPL.COM"
$EmailBody = "Hello All,`n`nPlease find the attached Mailbox Usage Report for $domain dated $date.`n`nRegards `nDeepak Gautam`""
$EmailFrom = "$env:USERDOMAIN\$env:USERNAME"
[string[]]$EmailTo = "deepakgautam139@outlook.com"
[string[]]$EmailCC = "deepakgautam139@gmail.com"
$EmailSubject = $Email_report_name
$SMTPServer = "smtp.office365.com"
$LogFolder = "C:\script\logs"
$LogFile = $LogFolder + "\" + (Get-Date -UFormat "%d-%m-%Y") + ".log"
$FileAged="8"
$Path="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WinRM\Client\"
$Name="allowbasic"
$value="1"
$PropertyType="Dword"
$ErrorActionPreference="stop"

if(!(Test-Path C:\script\reports))
{
    New-Item -Path C:\script\reports -ItemType Directory -Force
}

#Functions

Function remove-agedFiles {
    [CmdletBinding()]
        param (
            [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName)]
            [int]$days,

            [Parameter(Mandatory=$True,ValueFromPipelineByPropertyName)]
            [string]$collection
        )
    process{
     get-Childitem -Path $collection | `
     Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays($days * -1)} | `
     Remove-Item
    }
    
} 
    # Function to log any errors
    
    Function Write-Log
    {   
        [CmdletBinding()]
        param (
            [Parameter(Mandatory=$True)]
            [array]$LogOutput
        )
        if(!(Test-Path -Path C:\script\logs)){
            New-Item -Path C:\script\logs -ItemType Directory -Force
        }
        $currentDate = (Get-Date -UFormat "%d-%m-%Y")
        $currentTime = (Get-Date -UFormat "%T")
        $logOutput = $logOutput -join (" ")
        "[$currentDate $currentTime] $logOutput" | Out-File $LogFile -Append
    }



 function loginfo {
         [CmdletBinding()]
         param (
            [Parameter(Mandatory=$True)]
             [string]
             $message
         )
     Write-Host $message
     write-log $message
 }

 function get-requiredmodule {
     [CmdletBinding()]
     param (
         
     )
     
     begin {
         loginfo "Checking if ExchangeOnlineManagement Module is installed."
     }
     
     process {
        try {
            $Module = Get-Module ExchangeOnlineManagement -ListAvailable
            if($Module.count -eq 0) 
            { 
            loginfo "Exchange Online PowerShell V2 module is not available." 
            loginfo "Installing Exchange Online PowerShell module."
            Install-Module ExchangeOnlineManagement -Repository PSGallery -AllowClobber -Force
            } 
        }
        catch {
            $message=$Error[0].Exception.Message
            loginfo $message
            throw
        }   
     }
     
     end {
         Import-Module -Name ExchangeOnlineManagement
         loginfo "ExchangeOnlineManagement Module Imported."
     }
 }

 function get-Result {       #Function to verify result of the operation
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$result,

        [Parameter(Mandatory)]
        [string]$message

    )

    If($result -eq $true)
            {
            loginfo "$message successful"
            }
        else {
            $msg=$Error[0].Exception.Message
            loginfo $msg
            loginfo "$message failed"
            throw 
            }
}

#Main
function get-filepath {
    
    [CmdletBinding()]
    param (
        )
try {
    if((Test-Path $scriptpath\aeskey.key) -and (test-path $scriptpath\password.txt)){
        loginfo "Encryption key and password file"
    }    
}
catch {
    $message=$Error[0].Exception.Message
    loginfo $message
    throw
    }
}

function New-RecursiveItemProperty($Path,$Name,$Value,$PropertyType) {
    foreach($key in $Path.split("{\}")) {
        $currentPath += $key + "\"
        if (!(Test-Path $currentPath)) {
           New-Item -Path $currentPath    
        }
    }
    New-ItemProperty -Path $currentpath -Name $Name -value $value -PropertyType $PropertyType -Force
}

function Get-report {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$EmailFrom,

        [Parameter(Mandatory)]
        [string]$script_path,

        [Parameter(Mandatory)]
        [string]$Emailreportpath,

        [Parameter(Mandatory)]
        [string]$EmailReportName

    )
    
    begin {
        # Using the encrypted password again in the script

        $encrypted=Get-Content $scriptpath\password.txt | ConvertTo-SecureString -Key (Get-Content $scriptpath\aeskey.key)

        # Using the saved password and username in the credential

        $credential = New-Object System.Management.Automation.PSCredential($EmailFrom,$encrypted)

        # Connecting to Exchange Online
        loginfo "Connecting to Exchange Online"
        Connect-ExchangeOnline -Credential $credential
        get-Result -result "$?" -message "connection to Microsoft Exchange"        
    }
    
    process {
            # Retreiving report from Exchange Online
            try {
                $results=get-exomailbox -resultsize unlimited | `
                get-exomailboxstatistics -Properties MailboxType,LastLogonTime,IsArchiveMailbox,SystemMessageSize
                $results | Export-Csv -Path $Emailreport_path\$Email_report_name.csv -NoTypeInformation -Force
                get-Result -result "$?" -message "Report export"    
            }
            catch {
                $message=$Error[0].Exception.Message
                loginfo $message
                throw        
            }
            
    }
    
    end {
        # Disconnect ExchangeOnline session            
        Disconnect-ExchangeOnline -Confirm:$false
        get-Result -result "$?" -message "Disconnect"        
    }
}


# Main

Get-report -EmailFrom $EmailFrom -script_path $scriptpath -Emailreportpath $Emailreport_path -EmailReportName $EMail_report_name

# Setting Winrm to allow basic authentication

New-RecursiveItemProperty -Path $Path -Name $Name -Value $value -PropertyType $PropertyType

# Removing Files aged more than 8 days

remove-agedFiles -collection $Emailreport_path -days $FileAged 

# Sending Email with report as attachments

Send-MailMessage -From $EmailFrom -To $EmailTo -Cc $EmailCC -Subject $EmailSubject -body $EmailBody -SmtpServer $SMTPServer  -Credential $credential -UseSsl -Attachments $Emailreport_path\$Email_report_name.csv -DeliveryNotificationOption OnFailure
get-Result -result "$?" -message "Email"






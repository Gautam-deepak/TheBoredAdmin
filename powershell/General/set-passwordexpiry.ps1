##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepak.gautam@hpe.com                                                                                           #
#   Date :- 20-Oct-2022                                                                                                      #
#   Description :- Script is to Automate Password resets of Expired AD accounts                                              #
##############################################################################################################################


<#PSScriptInfo

.VERSION 1.0.0

.GUID 32dfcba9-41ed-406d-973d-9727d71fcd11

.AUTHOR Deepak.Gautam@hpe.com

.COMPANYNAME MIT

.COPYRIGHT MIT. All rights reserved.

.TAGS Tag1 Tag2 Tag3

.LICENSEURI https://contoso.com/License

.PROJECTURI https://contoso.com/

.ICONURI https://contoso.com/Icon

.EXTERNALMODULEDEPENDENCIES ff,bb 

.REQUIREDSCRIPTS Start-WFContosoServer,Stop-ContosoServerScript

.EXTERNALSCRIPTDEPENDENCIES Stop-ContosoServerScript

.RELEASENOTES
Contoso script now supports the following features:
Feature 1
Feature 2
Feature 3
Feature 4
Feature 5

.PRIVATEDATA

#>


#Requires -Module @{ModuleName = 'ActiveDirectory'; ModuleVersion = '1.0'}

<# 

.DESCRIPTION 

 Script is to Automate Password resets of Expired AD accounts

 #> 

# Variables


$scriptdirectory = "$env:HOMEDRIVE\windows\system32"

$scriptpath="C:\Windows\system32\PasswordExpiryAutomation.ps1"

$logFile = "$scriptdirectory\Pwdlogs.log"

If(!(Test-Path -Path $scriptdirectory\email_logs.csv)){
    $Email_log_init=[ordered]@{
        
        'Display Name'=""
        'SamAccountName'=""
        'Email'=""
        'Expiry_Date'=""
        'PwdReminder15'=""
        'PwdReminder7'=""
        'PwdReminder3'=""
        'PwdReminder2'=""
        'PwdReminder1'=""
        'Pwd_Expiry_Email'=""
        'ExpReminder25'=""
        'ExpReminder55'=""
        'Disable_date'=""
    }
    New-Object psobject -Property $Email_log_init | Export-Csv -path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
}

# Importing email log

$Email_logs=Import-Csv -Path $scriptdirectory\email_logs.csv 

# Getting details of all users
$users=Get-ADUser -filter {Enabled -eq $True -and PasswordNeverExpires -eq $False -and samaccountname -notlike "*$"} `
–Properties "displayname","sAMAccountname","passwordlastset","msDS-UserPasswordExpiryTimeComputed","msDS-User-Account-Control-Computed","mail" |`
Select-Object -Property "DisplayName","sAMAccountname","passwordlastset",@{Name="ExpiryDate";`
Expression={[datetime]::FromFileTime($_."msDS-UserPasswordExpiryTimeComputed")}},"msDS-User-Account-Control-Computed","mail"

# Users where password is going to expire today 

$expiretoday=$users | Where-Object {$_.ExpiryDate -match $date.GetDateTimeFormats()[0]}

# Users where password is going to expire in next 7 days

$ExpirenextUsers=$users | Where-Object {$_.ExpiryDate -ne "1/1/1601 5:30:00 AM" -and $_."msDS-User-Account-Control-Computed" -ne 8388608 -and `
$_.ExpiryDate -le (get-date).AddDays(15) -and $_.ExpiryDate -notmatch $date.GetDateTimeFormats()[0]}

# Users where password is already expired but it has been less than 60 days

$expiredle60=$users | Where-Object {$_."msDS-User-Account-Control-Computed" -eq 8388608 -and $_.expirydate -gt $date.AddDays(-60)} 

# Users where password is already expired but it has been more than 60 days

$expiredgt60=$users | Where-Object {$_."msDS-User-Account-Control-Computed" -eq 8388608 -and $_.expirydate -le $date.AddDays(-60)} 

$ErrorActionPreference='stop'

$WarningPreference='silentlycontinue'

$VerbosePreference = 'Continue'

$date=get-date

$PETask="Password Reset Automation-DO-NOT-DELETE"

# Functions 

Function Write-Log {
    <#
        .SYNOPSIS
        Describe purpose of "Write-Log" in 1-2 sentences.
  
        .DESCRIPTION
        Add a more complete description of what the function does.
  
        .PARAMETER messages
        Describe parameter -messages.
  
        .PARAMETER level
        Describe parameter -level.
  
        .EXAMPLE
        Write-Log -messages Value -level Value
        Describe what this call does
  
        .NOTES
        Place additional notes here.
  
        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online Write-Log
  
        .INPUTS
        List of input types that are accepted by this function.
  
        .OUTPUTS
        List of output types produced by this function.
    #>
  
    param(
      [Parameter(Mandatory = $true,HelpMessage='Add help message for user')][string[]] $messages,
      [ValidateSet('INFO','WARN','ERROR')]
      [string] $level = 'INFO'
    )
  
    # Create timestamp
    $timestamp = (Get-Date).toString('yyyy/MM/dd HH:mm:ss')
  
    # Append content to log file
    foreach($message in $messages){
        Add-Content -Path $logFile -Value ('{0} [{1}] [{2}] - {3}' -f $timestamp, $level,$env:COMPUTERNAME, $message)
        Start-Sleep -Seconds 2
    }
}
  
Function Get-status{
    <#
        .SYNOPSIS
        Describe purpose of "Get-status" in 1-2 sentences.
  
        .DESCRIPTION
        Add a more complete description of what the function does.
  
        .PARAMETER message
        Describe parameter -message.
  
        .EXAMPLE
        Get-status -message Value
        Describe what this call does
  
        .NOTES
        Place additional notes here.
  
        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online Get-status
  
        .INPUTS
        List of input types that are accepted by this function.
  
        .OUTPUTS
        List of output types produced by this function.
    #>
  
    param(
        [parameter(Mandatory=$true,HelpMessage='Add help message for user')]
        [string]$message
    )
    if( $? -eq $true ) {
        $messagefinal=$message+'- success'
        Write-log -level INFO -message $messagefinal
      } 
    else {
        $messagefinal=$message+'- failed'
        Write-log -level ERROR -message $messagefinal
    }
}
  
# Function Disable account 

function disable-ADusers {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,HelpMessage='Add help message for user')]
        [string[]]$users
    )
    
    begin {
        Write-Log -messages "Initiating User disabling Process"
    }
    
    process {
        try {
            Write-Log -messages "User disabling process started"
            foreach($user in $users){
                disable-ADaccount -identity $user.samaccountname 
                Get-status -message "$($user.samaccountname) disabled"
            }    
        }
        catch {
            write-log -message ('Error Happened while disabling $($user.samaccountname) :`
            {0} : {1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
        }
        finally{
            $error.Clear()
        }
    }
    end {
        Write-Log -messages "User disabling process completed"   
    }
}

# Task registration
function set-sctask {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true,HelpMessage='Add help message for user')]
        [string] $taskname
    )
    
    begin {
        
        Write-Log -messages "Checking if SCTask already exist or not"
        if(Get-ScheduledTask -TaskName $taskname){
            Write-Log -messages "Task already exist , hence skipping task creation"
            break
        }
    }
    
    process {
        
        try {
            
            Write-Log -messages "Creating task $taskname"

            # register schedule task forcefully so that the script runs at reboot
            $action = New-ScheduledTaskAction -Execute "${Env:WinDir}\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument ("-Command `"& '" + $scriptPath + "'`"")
            $trigger = New-ScheduledTaskTrigger -Daily -At 8AM
            $description="This task is to automate the password reset in ITOC. Please reach out to ITOC System Admin for clarifications."
            $principal = New-ScheduledTaskPrincipal -UserID 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest
            $null = Register-ScheduledTask -TaskName $PETask -Action $action -Trigger $trigger -Principal $principal -Description $description -Force
            Get-status -message 'Task Registration '    
        }
        catch {
            write-log -message ('Error Happened while creating SCTask :{0} : {1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
        }
        finally {
            $error.Clear()
        }      
    }
    
    end {
        Write-Log -messages "Task registration successfull"
    }
}

function get-password {
    param (
       [string]$length="15"
    )
    
    $Password = New-Object -TypeName PSObject
    $Password | Add-Member -MemberType ScriptProperty -Name "Password" -Value { `
    ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | `
    Sort-Object {Get-Random})[0..$length] -join '' }
    $Pass=$Password.Password
    $Pass
}

function reset-password {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,HelpMessage='Add help message for user')]
        [string]$user
    )
    
    begin {
        Write-Log -messages "Initiating Password reset for $($user.samaccountname)"
    }
    
    process {
        try {
            $Pass=get-password
            $password=ConvertTo-SecureString -String $Pass -AsPlainText -Force
            
            Set-ADAccountPassword -Identity $user -NewPassword $password -Reset
            Get-status -message "Password reset of $($user.samaccountname)"
            Set-ADUser -Identity $user -ChangePasswordAtLogon $true
            Get-status -message "Change Password at logon set of $($user.samaccountname)"    
            
        }
        catch {
            write-log -message ('Error Happened while resetting Password of $($user.samaccountname) :{0} : {1}' `
            -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
        }
        finally{
            $error.Clear()
        }
    }
    end {
        return $Pass
    }
}

function Send-email {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,HelpMessage='Add help message for user')]
        [string]
        $emailbody,
        [Parameter(Mandatory = $true,HelpMessage='Add help message for user')]
        [string[]]
        $targetusers,
        [Parameter(Mandatory=$false)]
        [string]$subject="User Account Management"
    )
        
    begin {
        [Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12
        Write-Log -messages "Initializing Email sending process"            
    }    
    process {        
        Write-Log -messages "Email process initialized"
        try {
            foreach($targetuser in $targetusers){        
                $smtp = New-Object System.Net.Mail.SmtpClient
                $to = New-Object System.Net.Mail.MailAddress($email)
                $from = New-Object System.Net.Mail.MailAddress("itocblrusermgmt@hpe.com")
                #$attachment="C:\Users\yyy1g92\Desktop\Sreeni\newlog.txt"
                $msg = New-Object System.Net.Mail.MailMessage($from, $to)
                $msg.subject = $subject
                $msg.body = $emailbody
                $msg.IsBodyHtml="True"
                #$msg.Attachments.Add($attachment)
                $smtp.host = "smtp1.hpe.com"
                $SMTP.Port = 25
                $smtp.send($msg)
                Get-status -message "Email sent to $($targetuser."Display name")"  
            }
        }
        catch {
            write-log -message ('Error Happened while sending email :{0} : {1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
        }
        finally {
            $error.Clear()
        } 
    }
        end {
            Write-Log -messages "Email Sending process completed"
        }
}

# Main 

$bodynextusers=@"
<p><strong>Please do not reply to this email. This is not a monitored mailbox. </strong></p>
<p><strong>Action required: Your $($env:USERDOMAIN) domain account password is about to expire! </strong></p>
<p>To: <strong>$($targetuser."display name") </strong></p>
<p>The password for the domain account you own <span style="color: #ff0000;"><strong>$($env:USERDOMAIN+"\"+$targetuser.samaccountname)</strong></span> has an expiration date of <strong><span style="color: #ff0000;">$($targetuser.expiry_date)</span></strong>.</p>
<p>NOTE: Even if your password meets policy requirements (regarding length, number and type of characters, and reuse), your password reset attempts may be rejected if your proposed password contains a word, phrase, or pattern that makes it more vulnerable to cybersecurity attacks.</p>
<p>To change/reset the password for your $($env:userdomain) domain account, first connect to the $($env:userdomain) network via Pulse Secure VPN and proceed with one of the following options:</p>
<p><strong>Using HPE-issued computer (with HPE standard operating system and software installed)</strong></p>
<p>&bull; <span style="color: #ff0000;"><strong>Login to $($env:userdomain) Jump,</strong></span>&nbsp;press Ctrl+Alt+End to display the Windows Security dialog box. Click Change Password to change your password.&nbsp;</p>
<p>&bull; <span style="color: #ff0000;"><strong>If you forgot your password, </strong><span style="color: #000000;">please email <strong><a style="color: #000000;" href="mailto:apj-gmswintel@hpe.com">apj-gmswintel@hpe.com</a></strong> for immediate assistance , otherwise</span><strong> </strong><span style="color: #000000;">it will be reset automatically and sent to you via email on <strong>$($targetuser.mail)</strong> by <strong>$($targetuser.expirydate)</strong>.</span></span></p>
<p>Thank you for changing your $($env:userdomain)&nbsp;domain account password every 90 days!</p>
<p><strong>ITOC BLR USER MANAGMENT</strong></p>
<p><strong>Managed By ITOC TSS</strong></p>
"@

$bodytoday=@"
<p><strong>Please do not reply to this email. This is not a monitored mailbox. </strong></p>
<p><strong>Action required: Your $($env:USERDOMAIN) domain account password has expired today! </strong></p>
<p>To: <strong>$($targetuser."display name") </strong></p>
<p>The password for the domain account you own <span style="color: #ff0000;"><strong>$($env:USERDOMAIN+"\"+$targetuser.samaccountname)</strong></span> has expired today.</p>
<p>NOTE: Even if your password meets policy requirements (regarding length, number and type of characters, and reuse), your password reset attempts may be rejected if your proposed password contains a word, phrase, or pattern that makes it more vulnerable to cybersecurity attacks.</p>
<p>Please find your new password : <strong>$(reset-password -user $targetuser)</strong></p>
<p>To change/reset the password for your $($env:userdomain) domain account, first connect to the $($env:userdomain) network via Pulse Secure VPN and proceed with one of the following options:</p>
<p><strong>Using HPE-issued computer (with HPE standard operating system and software installed)</strong></p>
<p>&bull; <span style="color: #ff0000;"><strong>Login to $($env:userdomain) Jump,</strong></span> use the password in the email and when prompted, type in new password to change your password.&nbsp;</p>
<p>&bull; <span style="color: #ff0000;"><strong>If you are unable to follow the steps, </strong><span style="color: #000000;">please email <strong><a style="color: #000000;" href="mailto:apj-gmswintel@hpe.com">apj-gmswintel@hpe.com</a></strong> for immediate assistance.</span></span></p>
<p>Thank you for changing your $($env:userdomain) domain account password every 90 days!</p>
<p><strong>ITOC BLR USER MANAGMENT</strong></p>
<p><strong>Managed By ITOC TSS</strong></p>
"@

$bodygt60=@"
<p><strong>Please do not reply to this email. This is not a monitored mailbox. </strong></p>
<p><strong>Action required: Your $($env:userdomain) domain account has been disabled.</strong></p>
<p>To: <strong>$($targetuser."display name") </strong></p>
<p>The domain account you own <span style="color: #ff0000;"><strong>$($env:USERDOMAIN+"\"+$targetuser.samaccountname)</strong></span> has been disabled due to inactivity for more than <strong>60 days</strong>.&nbsp;</p>
<p><span style="color: #ff0000;"><span style="color: #000000;">Please reach out to <strong><a href="mailto:apj-gmswintel@hpe.com">apj-gmswintel@hpe.com</a></strong>&nbsp; via email&nbsp;for immediate assistance.</span></span></p>
<p><strong>ITOC BLR USER MANAGMENT</strong></p>
<p><strong>Managed By ITOC TSS</strong></p>
"@

$bodyle60=@"
<p><strong>Please do not reply to this email. This is not a monitored mailbox. </strong></p>
<p><strong>Action required: Your $($env:USERDOMAIN) domain account password has expired.</strong></p>
<p>To: <strong>$($targetuser."display name") </strong></p>
<p>The password for the domain account you own <span style="color: #ff0000;"><strong>$($env:USERDOMAIN+"\"+$targetuser.samaccountname)</strong></span> was expired on <strong>$($targetuser.expirydate).</strong></p>
<p>NOTE: Even if your password meets policy requirements (regarding length, number and type of characters, and reuse), your password reset attempts may be rejected if your proposed password contains a word, phrase, or pattern that makes it more vulnerable to cybersecurity attacks.</p>
<p>Please find your new password : <strong>$(reset-password -user $targetuser)</strong></p>
<p>To change/reset the password for your $($env:userdomain) domain account, first connect to the $($env:userdomain) network via Pulse Secure VPN and proceed with one of the following options:</p>
<p><strong>Using HPE-issued computer (with HPE standard operating system and software installed)</strong></p>
<p>&bull; <span style="color: #ff0000;"><strong>Login to $($env:userdomain) Jump,</strong></span> use the password in the email and when prompted, type in new password to change your password.&nbsp;</p>
<p>&bull; <span style="color: #ff0000;"><strong>If you are unable to follow the steps, </strong><span style="color: #000000;">please email <strong><a style="color: #000000;" href="mailto:apj-gmswintel@hpe.com">apj-gmswintel@hpe.com</a></strong> for immediate assistance.</span></span></p>
<p><strong><span style="color: #ff0000;"><span style="color: #000000;">Failure to reset your password by $([Datetime]::ParseExact($targetuser.expirydate, 'MM/dd/yyyy', $null).AddDays(+7)) will result in disabling your account.&nbsp;</span></span></strong></p>
<p>Thank you for changing your $($env:userdomain) domain account password every 90 days!</p>
<p><strong>ITOC BLR USER MANAGMENT</strong></p>
<p><strong>Managed By ITOC TSS</strong></p>
"@


set-sctask -taskname $PETask

$email_logs=import-csv -Path $scriptdirectory\email_logs.csv
$filteredusers = $users | Select-Object Name,SamAccountName,mail,Expiry_Date
Foreach($targetuser in $filteredusers){
    
    if(!($Email_logs.SamAccountName -contains $targetuser.SamAccountName)){
    $targetuser | Export-Csv -NoTypeInformation -Force $scriptdirectory\email_logs.csv -Append
    } 
    
    $csv_targetuser=$email_logs | Where-Object {$Email_logs.SamAccountName -eq $targetuser.samaccountname}

    switch ($true) {
        
        ($ExpirenextUsers -contains $targetuser){
            $start=(Get-Date)
            $end=[datetime]$csv_targetuser.Expiry_Date
            $daysleft=(New-TimeSpan -Start $start -End $end).Days
            switch ($daysleft) {
                15 { 
        
                    # Reminder sent at 15 days before expiry of password

                    if ([string]::IsNullOrEmpty($csv_targetuser.PwdReminder15)){
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email) ){
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder15=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
                    else{
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email)){
                            if(([datetime]$csv_targetuser.Expiry_Date).AddDays(-15) -eq (Get-Date)){
                                Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                                $csv_targetuser.PwdReminder15=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                                $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                                break outer
                            }
                        }
                        elseif (([datetime]$csv_targetuser.pwd_expiry_email).AddDays(-85) -gt (Get-Date)) {
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder15=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
        
                }
                
                7 {  

                    # Reminder sent at 7 days before expiry of password

                    if ([string]::IsNullOrEmpty($csv_targetuser.PwdReminder7)){
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email) ){
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder7=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
                    else{
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email)){
                            if(([datetime]$csv_targetuser.Expiry_Date).AddDays(-7) -eq (Get-Date)){
                                Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                                $csv_targetuser.PwdReminder7=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                                $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                                break outer
                            }
                        }
                        elseif (([datetime]$csv_targetuser.pwd_expiry_email).AddDays(+85) -le (Get-Date)) {
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder7=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
        
                }
                
                3 {  

                    # Reminder sent at 3 days before expiry of password

                    if ([string]::IsNullOrEmpty($csv_targetuser.PwdReminder3)){
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email) ){
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder3=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
                    else{
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email)){
                            if(([datetime]$csv_targetuser.Expiry_Date).AddDays(-3) -eq (Get-Date)){
                                Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                                $csv_targetuser.PwdReminder3=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                                $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                                break outer
                            }
                        }
                        elseif (([datetime]$csv_targetuser.pwd_expiry_email).AddDays(+85) -le (Get-Date)) {
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder3=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
        
                }
                
                2 {  

                    # Reminder sent at 2 days before expiry of password

                    if ([string]::IsNullOrEmpty($csv_targetuser.PwdReminder2)){
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email) ){
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder2=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
                    else{
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email)){
                            if(([datetime]$csv_targetuser.Expiry_Date).AddDays(-2) -eq (Get-Date)){
                                Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                                $csv_targetuser.PwdReminder2=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                                $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                                break outer
                            }
                        }
                        elseif (([datetime]$csv_targetuser.pwd_expiry_email).AddDays(+85) -le (Get-Date)) {
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder2=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
                }
                
                1 {  

                    # Reminder sent at 1 day before expiry of password

                    if ([string]::IsNullOrEmpty($csv_targetuser.PwdReminder15)){
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email) ){
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder1=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
                    else{
                        if([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email)){
                            if(([datetime]$csv_targetuser.Expiry_Date).AddDays(-1) -eq (Get-Date)){
                                Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                                $csv_targetuser.PwdReminder1=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                                $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                                break outer
                            }
                        }
                        elseif (([datetime]$csv_targetuser.pwd_expiry_email).AddDays(+85) -le (Get-Date)) {
                            Send-email -emailbody $bodynextusers -targetusers $targetuser -subject "Reminder : User Account Management"
                            $csv_targetuser.PwdReminder1=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                            $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                            break outer
                        }
                    }
                }
            }
        }
        ($expiretoday -contains $targetuser) {
            
            if ([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email)){
                    Send-email -emailbody $bodytoday -targetusers $targetuser
                    $csv_targetuser.pwd_expiry_email=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                    $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                    break outer
            }
            
            else{
                if (([datetime]$csv_targetuser.pwd_expiry_email).AddDays(+80) -le (Get-Date)) {
                    Send-email -emailbody $bodytoday -targetusers $targetuser
                    $csv_targetuser.pwd_expiry_email=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                    $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                    break outer
                }
            }
        }
        ($expiredle60 -contains $targetuser){
            
            # need to discuss what to do with those accounts whose password already expired less than 60 

            if (!([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email))){
                # Reminder 25
                if (([datetime]$csv_targetuser.pwd_expiry_email).AddDays(+25) -eq (Get-Date)) {
                    Send-email -emailbody $bodyle60 -targetusers $targetuser 
                    $csv_targetuser.ExpReminder25=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                    $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                    break outer
                }
                # Reminder 55
                elseif ((([datetime]$csv_targetuser.pwd_expiry_email).AddDays(+55) -eq (Get-Date))) {
                    Send-email -emailbody $bodyle60 -targetusers $targetuser 
                    $csv_targetuser.ExpReminder55=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                    $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                    break outer
                }
            }
        }

        ($expiredgt60 -contains $targetuser){

            # need to discuss what to do with those accounts whose password already expired more than 60 

            if(!([string]::IsNullOrEmpty($csv_targetuser.pwd_expiry_email))){
                if (([string]::IsNullOrEmpty($csv_targetuser.disable_date)) -or `
                ([datetime]$csv_targetuser.pwd_expiry_email).AddDays(+60) -le (Get-Date)){
                    Send-email -emailbody $bodygt60 -targetusers $targetuser
                    disable-ADusers -users $targetuser
                    $csv_targetuser.disable_date=(Get-Date -Format 'MM/dd/yyyy hh:mm')
                    $Email_logs | export-csv -Path $scriptdirectory\email_logs.csv -Force -NoTypeInformation
                    break outer
                }
            }   
        }
    }
}

function update-email_logs {
    [CmdletBinding()]
    param (
        [parameter(Mandatory=$true)]
        [string]$field
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}


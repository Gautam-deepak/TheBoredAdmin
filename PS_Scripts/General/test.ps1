# Requirements

# Set Events in remote machine to "do not overwrite".
# set events in remote machine to be stored for 30 days.
# Change default location of all events to separate drive for extra storage
# A scheduled task will be configured to run every 30 days on remote machine to copy events to file server and then clear events

# Additional

# An event retrieval script will take name of the computer to check the stored logs on file server
# Once events are found, they will be automatically imported to event viewer for easy access or to excel
# An option to filter logs by event id and auto export to event viewer or excel

#https://docs.microsoft.com/en-us/troubleshoot/windows-server/application-management/move-event-viewer-log-files

$computers=Get-Content -Path C:\Temp\computers.txt
$ErrorActionPreference="stop"
$Eventlog="HKLM:\SYSTEM\CurrentControlSet\Services\EventLog"
$eventnewpath="E:\Events"
$Logs="Application,system,security"

if (test-path $eventnewpath) {
    New-item -Path $eventnewpath -Name "Events" -ItemType Directory -Force
}

$results = foreach ($computer in $Computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {
            
            Invoke-Command -ComputerName $Computer -ScriptBlock { param ($logs,$Eventlog,$eventnewpath)
                foreach ($log in $logs) {
                    Limit-EventLog -OverflowAction DoNotOverwrite -RetentionDays 30 -LogName $log;        
                    New-ItemProperty -Path (-join($Eventlog,"\","$log")) -Name "file" -Value (-join("$eventnewpath","\",$log,".evtx")) -PropertyType "ExpandString" -Force;
                }
            } -ArgumentList @("Application","system","security"),"HKLM:\SYSTEM\CurrentControlSet\Services\EventLog","E:\Events"
            $status = "Success"
            $issue="No Error"

     } 
     Catch {

            $status = "Failed"
            $issue=$($Error[0].exception.message)

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        $status = "Unreachable"
        $issue="Destination host is not reachable"
    }
    
    [pscustomobject]@{
        'Computer'=$computer
        'Status'=$status
        'Error'=$issue
    }
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force

#com-object

$newobject=New-Object -TypeName System.Diagnostics.Eventing.Reader.EventLogConfiguration -ArgumentList system

$newobject.LogFilePath="C:\event\system.evtx"

# WMI
$SecurityLogs = Get-WmiObject Win32_NTEventLogFile | Where-Object {$_.LogFileName -like "Security"}
$SecurityLogs.name="C:\event\security.evtx"


$Run = $true
$VPN = ""
Do{
$Option = Read-Host -Prompt 'Start or Kill?'

If ($Option -eq 'Start'){
Write-Host 'Starting Pulse Secure'
Start-Process $VPN
Start-Service -Name "Pulse Secure Service"
& 'C:\Program Files (x86)\Common Files\Pulse Secure\JamUI\Pulse.exe'
Break
}
ElseIf ($Option -eq 'Kill'){
Write-Host 'Killing Pulse Secure'
Stop-Service -Name "Pulse Secure Service"
Stop-Process -Name "Pulse"
Break
}
ElseIf ($Option -eq 'Exit'){
Exit
}
Else{
Write-Host 'Invalid Option'}
}until($Run -eq $false)


$pulsesecure=Get-NetAdapter | Where-Object {$_.InterfaceDescription -eq "Juniper Networks Virtual Adapter"}
if($null -eq $pulsesecure){
    Write-Host "Please connect Pulse Secure to continue"
    Start-Sleep -Seconds 10
    $credential=get-credential
    $username=$credential.username
    $password=$credential.getnetworkcredential().password
    $arguments="-u $username -p $password -url $url -r users"
    Set-Location -Path "C:\Program Files (x86)\Common Files\Pulse Secure\JamUI"
    .\Pulse.exe -show
    Start-Sleep -Seconds 2
    Start-process "C:\Program Files (x86)\Common Files\Pulse Secure\Integration\pulselauncher.exe" -argumentlist $arguments
    Start-Sleep -Seconds 25
    $pulsesecure=Get-NetAdapter | Where-Object {$_.InterfaceDescription -eq "Juniper Networks Virtual Adapter"}
    if ($pulsesecure.status -eq "up") {
        Write-Host "Pulse Secure Connected Successfully"
    }
}
else {
    Write-Host "Pulse Secure already connected"
}


Write-Host "Checking Zscalar services..."
Start-Sleep -Seconds 3
$zsaservices=@("zsaservice","zsatunnel","zsatraymanager")
foreach ($service in $zsaservices) {
    if((Get-Service -Name $service).Status -eq "running"){
    write-host $service is up and running
    }
    else {
        Write-Host $service is not running
    }
}

$filter = "<filter>"
$searchbase = "OU=Test,DC=golu,DC=com"



$OUs = Get-ADOrganizationalUnit -filter $filter -SearchBase $searchbase | Select-Object name,distinguishedname



$report = foreach ($OU in $OUs) {
$strOU = $OU | Select-Object -ExpandProperty distinguishedname
$ACLs = Get-Acl -Path "AD:\$strOU" | Select-Object -ExpandProperty Access |
Sort-Object {$_.identityreference} -Unique |
Where-Object {($_.identityreference -like "*domain\*") `
-and ($_.identityreference -notlike "*exchange*") `
-and ($_.identityreference -notlike "*admins*") `
-and ($_.identityreference -notlike "*group*")
}

foreach ($acl in $acls) {
[PSCustomObject]@{
OUName = $OU.name
UsersWithAccess = Get-ADUser $acl.IdentityReference.Value.Substring(6) | Select-Object -ExpandProperty name
}
}
}



$report | Export-Csv c:\OU_Security.csv -NoTypeInformation

$username="administrator"
$password=Read-Host "Enter the password for Local Admin Account" -AsSecureString
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Uninstall-ADDSDomainController -LocalAdministratorPassword $credential.Password -forceremoval:$true `
-skipprechecks -confirm:$false 
Uninstall-WindowsFeature AD-Domain-Services -IncludeManagementTools

#requires -version 2.0

Function New-Popup {

    <#
    .Synopsis
    Display a Popup Message
    .Description
    This command uses the Wscript.Shell PopUp method to display a graphical message
    box. You can customize its appearance of icons and buttons. By default the user
    must click a button to dismiss but you can set a timeout value in seconds to 
    automatically dismiss the popup. 
    
    The command will write the return value of the clicked button to the pipeline:
      OK     = 1
      Cancel = 2
      Abort  = 3
      Retry  = 4
      Ignore = 5
      Yes    = 6
      No     = 7
    
    If no button is clicked, the return value is -1.
    .Example
    PS C:\> new-popup -message "The update script has completed" -title "Finished" -time 5
    
    This will display a popup message using the default OK button and default 
    Information icon. The popup will automatically dismiss after 5 seconds.
    .Notes
    Last Updated: April 8, 2013
    Version     : 1.0
    
    .Inputs
    None
    .Outputs
    integer
    
    Null   = -1
    OK     = 1
    Cancel = 2
    Abort  = 3
    Retry  = 4
    Ignore = 5
    Yes    = 6
    No     = 7
    #>
    
    Param (
    [Parameter(Position=0,Mandatory=$True,HelpMessage="Enter a message for the popup")]
    [ValidateNotNullorEmpty()]
    [string]$Message,
    [Parameter(Position=1,Mandatory=$True,HelpMessage="Enter a title for the popup")]
    [ValidateNotNullorEmpty()]
    [string]$Title,
    [Parameter(Position=2,HelpMessage="How many seconds to display? Use 0 require a button click.")]
    [ValidateScript({$_ -ge 0})]
    [int]$Time=0,
    [Parameter(Position=3,HelpMessage="Enter a button group")]
    [ValidateNotNullorEmpty()]
    [ValidateSet("OK","OKCancel","AbortRetryIgnore","YesNo","YesNoCancel","RetryCancel")]
    [string]$Buttons="OK",
    [Parameter(Position=4,HelpMessage="Enter an icon set")]
    [ValidateNotNullorEmpty()]
    [ValidateSet("Stop","Question","Exclamation","Information" )]
    [string]$Icon="Information"
    )
    
    #convert buttons to their integer equivalents
    Switch ($Buttons) {
        "OK"               {$ButtonValue = 0}
        "OKCancel"         {$ButtonValue = 1}
        "AbortRetryIgnore" {$ButtonValue = 2}
        "YesNo"            {$ButtonValue = 4}
        "YesNoCancel"      {$ButtonValue = 3}
        "RetryCancel"      {$ButtonValue = 5}
    }
    
    #set an integer value for Icon type
    Switch ($Icon) {
        "Stop"        {$iconValue = 16}
        "Question"    {$iconValue = 32}
        "Exclamation" {$iconValue = 48}
        "Information" {$iconValue = 64}
    }
    
    #create the COM Object
    Try {
        $wshell = New-Object -ComObject Wscript.Shell -ErrorAction Stop
        #Button and icon type values are added together to create an integer value
        $wshell.Popup($Message,$Time,$Title,$ButtonValue+$iconValue)
    }
    Catch {
        #You should never really run into an exception in normal usage
        Write-Warning "Failed to create Wscript.Shell COM object"
        Write-Warning $_.exception.message
    }
    
    } #end function

    $r = New-Popup -Title "Help Update" -Message "Do you want to update help now?" -Buttons YesNo -Time 5 -Icon Question
if ($r -eq 6) {
  Update-Help -SourcePath \\jdh-nvnas\files\PowerShell_Help -Force
}



New-NetFirewallRule -DisplayName "Allow PSWindowsUpdate" -Direction Inbound -Program "%SystemRoot%\System32\dllhost.exe" -RemoteAddress Any -Action Allow -LocalPort 'RPC' -Protocol TCP

$stopwatch=[System.Diagnostics.Stopwatch]::StartNew() ;
$results=foreach($item in $computers) {
    
    Write-Host "Patching $item" -ForegroundColor "green"

    If (test-connection -ComputerName $item -Count 1 -Quiet)
    {
        Try {

        if ($null -eq (get-windowsupdate -ComputerName $item) ) {
            $status="No Patching Required"
            $issue="No Issue"
            $KBinstalled="No KB Installed"
            $difference="No Difference"
            $uptime="No Uptime"
        }
        else{    
            # Initializing counter variable for each computer
            $counter=@{}    
            # Adding computer name to the counter variable with counter 0
            $counter.add('$item','0')

        # Copying local module to remote session
            try{
            Copy-Item -Path "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\pswindowsupdate" `
                    -Destination "\\$item\c$\Windows\system32\WindowsPowerShell\v1.0\Modules" -Recurse -force;
            
            Invoke-Command -ComputerName $item -ScriptBlock {
                Import-Module 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate\2.2.0.2\PSWindowsUpdate.psd1'}
            }
            catch{
            
            $status="No Patching Done"
            $issue=$($Error[0].exception.message)
            $KBinstalled="No KB Installed"
            $difference="No Difference"
            $uptime="No Uptime"
            
            }

        # Starting do loop

        do {
        
            Install-WindowsUpdate -ComputerName $item -AcceptAll -IgnoreReboot -Confirm:$false ;
            
            #Get-WUServiceManager -ComputerName $item | Where-Object {$item.IsDefaultAUService -eq "true"} | Select-Object ComputerName,IsDefaultAUService,Name;

            if((Get-WURebootStatus -ComputerName $item | Select-Object RebootRequired).rebootrequired -eq $true) {
                if($counter['$item'] -eq "0"){
        
                Write-Host "Reboot required on $item" -ForegroundColor "red";
                
                $previousStatus = (get-service -ComputerName $computername | Where-Object{$item.Status -eq "Running"} | Select-Object -Property Name).Name
                
                Restart-Computer -Wait -For PowerShell -ComputerName $item -Credential $credential -Timeout 600 -Delay 5 -Force;
                
                $counter['$item']++;
                
                $poststatus=(get-service -ComputerName $computername | Where-Object{$item.Status -eq "Running"} | Select-Object -Property Name).Name;
    
                # Compare previous and current status
                if($null -eq (($previousStatus | Where-Object {$poststatus -notcontains $item}) -join ",")){
                    $difference = "No difference"
                    }
                else{
                    $difference = ($previousStatus | Where-Object {$poststatus -notcontains $item}) -join ","
                }
                $uptime=[System.Management.ManagementDateTimeconverter]::ToDateTime($(Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem  | `
                    Select-Object -ExpandProperty LastBootUpTime))
            }
            else {
                write-host "another Reboot required - so skipping on $item" -ForegroundColor "green";
            }
        }
        else{
            Write-Host "Reboot not required on $item" -ForegroundColor "green";
        }

        $installedKB=(Get-WUHistory -ComputerName $item | `
        Where-Object {(get-date).AddDays((-600)) -le $_.installedon} | `
        Select-Object hotfixID -ExpandProperty hotfixID) -join ','

     } while ($counter['$item'] -lt "2")

            $status = "Patched"
            $issue="No Error"
            $KBinstalled=$installedKB
            $difference=$difference
            $uptime=$uptime

        }
    

        } Catch {

            $status = "Failed"
            $issue=$($Error[0].exception.message)
            $KBinstalled=$installedKB
            $difference=$difference
            $uptime=$uptime

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        $status = "Unreachable"
        $issue="Destination host is not reachable"
        $KBinstalled="No KB Installed"
        $difference="No Difference"
        $uptime="No Uptime"
    }
    
    [pscustomobject]@{
        'Computer'=$item
        'Status'=$status
        'Error'=$issue
        'KBinstalled'=$KBinstalled
        'difference_services'=$difference
        'Reboot'=$uptime
    }
} 
#-ThrottleLimit 10 -AsJob | Receive-Job -Wait -AutoRemoveJob
$stopwatch.stop();
$stopwatch.elapsed.seconds ;

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force



##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepakgautam139@gmail.com                                                                                           #
#   Date :- 25-May-2021                                                                                                      #
#   Description :- Script is to set registry on the remote computers.                                                        #
##############################################################################################################################


#Variables

$Computers = Get-Content "C:\computerlist.txt" # File that contains server list
$ErrorActionPreference="Stop"

Write-host "
     ########################################################################################
     #                                                                               		#
     #      Welcome to the command line utility to create registry on remote computer		#
     #                                                                                		#
     ########################################################################################
																							 "

     Start-Sleep -Seconds 2

$results = foreach ($computer in $Computers) # Lopping through Computers
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet) # Checking if remote computer is reachable
    {
        Try {
           
            Invoke-Command -ComputerName $Computer -ScriptBlock {
            param($path,$property,$value) New-ItemProperty -Path $path -Name $Property -Value $Value -Type 'DWord' -Force | Out-Null
            } -ArgumentList "HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate","DisableDualScan","0" # creating registry on remote computer
            $status = "Success" # Saving Status
            $issue="No Error"	# Saving error

        } Catch {

            $status = "Failed" # Saving Status
            $issue=$($Error[0].exception.message) #Saving Error

        }

        Finally{
            $Error.Clear() # Clearing the error for next loop
        }
    }
    else
    {   
        $status = "Unreachable" #Saving Status
        $issue="Destination host is not reachable" # Saving error
    }
    
    [pscustomobject]@{
        'Computer'=$computer
        'Status'=$status
        'Error'=$issue
    } # Saving status, error and computer name in a PS Custom Object later to be retrieved.
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force #Publishing results


Function get-Sizedetails{
    param(
    [parameter(mandatory=$true)]
    [string]$path,
    [parameter(mandatory=$true)]
    [int]$top
    )

Get-ChildItem -Path $path -Recurse -ErrorAction SilentlyContinue | `
Select-Object Name,directory,length,LastWriteTime | `
Sort-Object Length -Descending  | `
Format-Table -AutoSize -Wrap -Property name,directory,@{label="Size in GB"; Expression={ "{0:N2}" -f ($_.length/1GB)}},lastwritetime | `
Select-Object -First $top 

}

get-Sizedetails -path "c:\" -top "10"


Invoke-Command -ComputerName $computer -scriptblock {Get-Content "c:\temp\windowsupdate.txt" -wait -Tail "0"}


$computers="win1"
Invoke-Command -ComputerName win1 -ScriptBlock{
   Write-Host ('Triggering Patching Task on {0}' -f $using:computers) -ForegroundColor Green;
   Start-ScheduledTask -TaskName patching;
   start-sleep -Seconds 2; 
   Get-Content -Path "c:\temp\WindowsUpdate.txt" -tail 0 -wait
}

<#
$roles=(Get-WindowsFeature | Where-Object {$_.installed -eq $true -and $_.featuretype -eq "role" -and $_.name -ne "AD-Domain-Services" -and $_.name -ne "DNS"} | `
Select-Object Name -ExpandProperty Name) -join ","

$site=get-addomaincontroller | Select-Object -ExpandProperty site
#>



$computers=Get-ADDomainController -Filter * | Select-Object hostname -ExpandProperty hostname


$ErrorActionPreference="Stop"

##############################################################################################################################
# Author :- Deepak Gautam 
# Email :- deepakgautam139@gmail.com
# Date :- 22-April-2021
# Description :- Script is to rename a single computer and reboot thereafter
#############################################################################################################################

using namespace System.Management.Automation.Host 

#Variables

$computername=$env:COMPUTERNAME # Auto fetch old computer name
$ErrorActionPreference='silentlycontinue'
$LogFolder = "C:\Temp\"
$LogFile = $LogFolder + "\" + (Get-Date -UFormat "%d-%m-%Y") + ".log"

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

#Functions
function get-Result {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$result
    )

    If($result -eq $true)
            {
            Write-Host "Computer successfully renamed to $NewComputerName, please wait until system reboots." -ForegroundColor "Green"
            write-log "$computername Computer successfully renamed to $NewComputerName"
            }
        else {
            Write-host $Error[0].exception.message -ForegroundColor "red"
            Write-Log $error[0].exception.message
            }
}
         
# Main
Write-Host "Welcome to the Computer Rename Command line utility." -ForegroundColor "Green"

Write-host "`nPlease provide the admin credentials to rename the computer. for e.g. domain\username" -ForegroundColor "Green"

$Credential = Get-Credential # Enter Credentials

    $Local = [ChoiceDescription]::new('&Local', 'Environment:Localhost') 
    $Remote = [ChoiceDescription]::new('&Remote', 'Environment:Remote')  
    $Envs = [ChoiceDescription[]]($Local,$Remote) 
    $choice = $host.ui.PromptForChoice("Select Environment", "Local , Remote", $envs, 0) 

    switch ($choice){ 
        0{ 
            Write-Host "`nYou have selected to rename Local Computer " 
            Write-Host "Current computer name is $computername." -ForegroundColor "Blue"
            $NewComputerName = read-host 'Enter the New Computer Name' # Enter new computer name
            Rename-Computer -ComputerName "$computername" -NewName "$NewComputerName" -DomainCredential $Credential -Force -Restart # Rename the host
            get-Result -result "$?"
            
        }

        1{ 
            Write-Host "`nYou have selected to rename Remote Computer"
            Write-Host "`nYou have selected to rename remote Computer " 
            $RemoteComputerName = read-host 'Enter the name of the Remote Computer' # Enter new computer name
            $NewComputerName = read-host 'Enter the New Computer Name' # Enter new computer name
            Rename-Computer -computerName "$remotecomputername" -NewName "$NewComputerName" -DomainCredential $Credential -Force -Restart # Rename the host
            get-Result -result "$?"
        } 
    }

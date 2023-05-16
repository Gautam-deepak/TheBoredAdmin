

##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepakgautam139@gmail.com                                                                                           #
#   Date :- 17-May-2021                                                                                                      #
#   Description :- Script is to move users\computers in target OU                                                            #
##############################################################################################################################

using namespace System.Management.Automation.Host 

#Variables

$computername=$env:COMPUTERNAME # Auto fetch old computer name
$LogFolder = "C:\Temp\" # Log Folder
$LogFile = $LogFolder + "\" + "Move-ADobject-"+ (Get-Date -UFormat "%d-%m-%Y") + ".log" # Log File

#Functions
Function Write-Log # Function to write log
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

    function loginfo {      # Function to easy use write-log
        [CmdletBinding()]
        param (
            
            [Parameter(Mandatory=$true)]
            [string]$message
        )
        
        Write-Host $message
        Write-Log $message
}

function get-Result {       #Function to verify result of the operation
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$result
    )

    If($result -eq $true)
            {
            $message= "ADObject successfully moved to $targetOU."
            loginfo $message
            }
        else {
            $message=$Error[0].Exception.Message
            loginfo $message
            }
}

function ConvertFromDN {
    param (
        [Parameter(Mandatory, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$dn
    )
    process {
        if ($dn) {
            $d = ''; $p = '';
            $dn -split '(?<!\\),' | ForEach-Object { if ($_ -match '^DC=') { $d += $_.Substring(3) + '.' } else { $p = $_.Substring(3) + '\' + $p } }
            Write-Output ($d.Trim('.') + '\' + ($p.TrimEnd('\') -replace '\\,',','))
        }
    }
}

function ConvertFrom-CanonicalUser {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$CanonicalName
    )
    process {
        $obj = $CanonicalName.Split('/')
        [string]$DN = 'CN=' + $obj[$obj.count - 1]
        for ($i = $obj.count - 2; $i -ge 1; $i--) { $DN += ',OU=' + $obj[$i] }
        $obj[0].split('.') | ForEach-Object { $DN += ',DC=' + $_ }
        return $DN
    }
}

function ConvertFromDN {
    param (
        [Parameter(Mandatory, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$dn
    )
    process {
        if ($dn) {
            $d = ''; $p = '';
            $dn -split '(?<!\\),' | ForEach-Object { if ($_ -match '^DC=') { $d += $_.Substring(3) + '.' } else { $p = $_.Substring(3) + '\' + $p } }
            Write-Output ($d.Trim('.') + '\' + ($p.TrimEnd('\') -replace '\\,',','))
        }
    }
}


#Main

if(!(Test-Path $LogFolder)){
    new-item -Path $LogFolder -ItemType Directory -Force
}

Write-host "

     #####################################################################################
     #                                                                                   #
     #              Welcome to the command line utility to move AD-Objects               #
     #                                                                                   #
     #####################################################################################
                                                                                            "

     Start-Sleep -Seconds 1

Write-host "`nPlease provide the admin credentials to move the objects. for e.g. domain\username" -ForegroundColor "Green"

$Credential = Get-Credential # Enter Credentials

    $User = [ChoiceDescription]::new('&User', 'Environment:User') 
    $computer = [ChoiceDescription]::new('&Computer', 'Environment:Computer')  
    $Envs = [ChoiceDescription[]]($User,$computer) 
    $choice = $host.ui.PromptForChoice("Select Item", "User , Computer", $envs, 0) 

    switch ($choice){ 
        0{ 
            Write-Host "`nYou have selected to move an user " 
            $Username = read-host "Enter the user's samaccountname" # Enter new computer name
            try{
            $userdn=(Get-ADUser -Identity $Username).distinguishedname
            $TargetOU= read-host "Enter the target OU"
            Move-ADObject -Identity $Userdn -TargetPath $TargetOU -Credential $Credential
            get-Result -result "$?"
            
            }
            catch {
                $message= "There was a problem with the operation, Please check logs at $logfile"
                loginfo $message
                if($Error[0].Exception.Message -contains "Access is denied")
                 {
                 loginfo "You don't have permission to move user-$username into the $targetOU OU."
                 }
                Write-Log $Error[0].Exception.Message
            }
            
        }

        1{ 
            Write-Host "`nYou have selected to move a computer " 
            $computername = read-host "Enter the comptuer's name" # Enter new computer name
            try{
            $computerdn=(Get-ADComputer -Identity $computername).distinguishedname
            $TargetOU= read-host "Enter the target OU"
            Move-ADObject -Identity $computerdn -TargetPath $TargetOU -Credential $Credential
            get-Result -result "$?"
            
            }
            catch {
                $message= "There was a problem with the operation, Please check logs at $logfile"
                loginfo $message
                 if($Error[0].Exception.Message -contains "Access is denied")
                 {
                 loginfo "You don't have permission to move computer-$computername into the $targetOU OU."
                 }
                 Write-Log $Error[0].Exception.Message
            }
            
        } 
    }


    
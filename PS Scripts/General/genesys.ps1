###########################################################################################################################################
#   Author :- Deepak Gautam                                                                                                               #
#   Email :- deepak.gautam@hpe.com                                                                                                        #
#   Date :- 12-Sept-2021                                                                                                                  #
#   Description :- Script is to remove cache/cookies and check pulse secure connection to remedy continous login problem with genesys.    #
###########################################################################################################################################


#Variables

$Genesys = 'Genesys*'
$Zscaler = 'Zscaler'
$PulseSecure = 'Pulse Secure'
$zsaservices=@('zsaservice','zsatunnel','zsatraymanager')
$pulsesecureadapter=Get-NetAdapter | Where-Object {$_.InterfaceDescription -like 'Juniper Networks Virtual Adapter*'}
$argument='-show'
$pulsepath="${env:CommonProgramFiles(x86)}\Pulse Secure\JamUI\pulse.exe"
$pacvalue='http://127.0.0.1:9000/systemproxy-1627653278.pac'
$pacreg='HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings\'
$pacname='autoconfigurl'
$softwares=@($Zscaler,$PulseSecure,$Genesys)
$LogFolder = "$env:HOMEDRIVE\Temp\" # Log Folder
$LogFile = $LogFolder + '\' + 'Genesys-'+ (Get-Date -UFormat '%d-%m-%Y') + '.log' # Log File


Write-host '
     #####################################################################################
     #                                                                                   #
     #              Welcome to the command line cleanup utility for Genesys              #
     #                                                                                   #
     #####################################################################################' 

     Start-Sleep -Seconds 1

# Functions

Function Write-Log # Function to write log
{
  <#
      .SYNOPSIS
      Describe purpose of "Write-Log" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER LogOutput
      Describe parameter -LogOutput.

      .EXAMPLE
      Write-Log -LogOutput Value
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


  param (
        [Parameter(Mandatory,HelpMessage='Add help message for user')]
        [array]$LogOutput
  )
  $currentDate = (Get-Date -UFormat '%d-%m-%Y')
  $currentTime = (Get-Date -UFormat '%T')
  $logOutput = $logOutput -join (' ')
  ('[{0} {1}] {2}' -f $currentDate, $currentTime, $logOutput) | Out-File -FilePath $LogFile -Append
}

    function script:loginfo {
      <#
        .SYNOPSIS
        Describe purpose of "loginfo" in 1-2 sentences.

        .DESCRIPTION
        Add a more complete description of what the function does.

        .PARAMETER message
        Describe parameter -message.

        .EXAMPLE
        loginfo -message Value
        Describe what this call does

        .NOTES
        Place additional notes here.

        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online loginfo

        .INPUTS
        List of input types that are accepted by this function.

        .OUTPUTS
        List of output types produced by this function.
      #>

      # Function to easy use write-log
        param (
            
            [Parameter(Mandatory,HelpMessage='Add help message for user')]
            [string]$message
        )
        
        Write-Verbose -Message $message -Verbose
        Write-Log -LogOutput $message
}

# 1. Check Pulse VPN is connected or not - can be checked using Get-netadaptor command, then we can apply a wait loop and pop up pulse secure to connect before proceeding further.

function Get-PulseStatus {
  <#
      .SYNOPSIS
      Function is to check whether pulse secure is connected or not

      .DESCRIPTION
      Function uses Get-NetAdapter command to verify if Pulse secure is connected or not, if it isn't opens up Pulse secure and prompt user to connect first.

      .PARAMETER pulsestatus
      Parameter takes the filtered output of Get-NetAdapter using InterfaceDescription as Juniper Networks Virtual Adapter.

      .EXAMPLE
      Get-PulseStatus -pulsestatus Value

      Value is a variable which have filtered output of Get-NetAdapter using InterfaceDescription as 'Juniper Networks Virtual Adapter'
      If Pulse Secure is connected the output will be a message saying Pulse Secure is connected
      If Pulse Secure is not connected , Script will terminate after popping the Pulse Secure Application to the user with a message to connect the Pulse Secure first.

      .NOTES
      Function help can be accessed by :-

      Get-help Get-PulseStatus -examples

      .INPUTS
      Only String Inputs are allowed. Empty and null strings are allowed as well.

      .OUTPUTS
      Pulse Secure connected:- 
      VERBOSE: Checking Pulse Secure Status
      VERBOSE: Pulse Secure is connected

      Pulse Secure is not connected:- 
      VERBOSE: Checking Pulse Secure Status....
      VERBOSE: Please connect Pulse Secure first to continue
      VERBOSE: Exiting Script..
  #>


  param (
    [Parameter(Mandatory,HelpMessage='filtered output of Get-NetAdapter using InterfaceDescription as Juniper Networks Virtual Adapter')][AllowEmptyString()][string]$pulsestatus
  )
    
  begin {
    Write-Verbose -Message 'Checking Pulse Secure Status....' -Verbose
        
  }
    
  process {
    try {
      if($null -eq $pulsesecureadapter){
        Write-Verbose -Message 'Please connect Pulse Secure first and re-run the script' -Verbose
        Start-Process -FilePath $pulsepath -ArgumentList $argument
        Write-verbose -Message 'Exiting Script..GoodBye' -Verbose
        Start-Sleep -Seconds 1 
        break
      }
    }
    catch {
      $issue=$($Error[0].exception.message)
      Write-Verbose -Message $issue -Verbose
      break
    }
  }
    
  end {
    Write-Verbose -Message 'Pulse Secure is connected' -Verbose
  }
}



# 2. Chrome cache(and cookies) be cleared (everytime it opens) - can be done by converting .ps1 to .exe and then .exe will launch chrome itself or users can do a manual setting - need to confirm
#.exe works
function Remove-cacheCookiesChrome {
  <#
      .SYNOPSIS
      Describe purpose of "Remove-cacheCookiesChrome" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      Remove-cacheCookiesChrome
      Running the following functions removes the caches and cookies of chrome. First, it closes any current Chrome tasks , clear cookies and caches and re-open a new Chrome task.

      .NOTES
      Following folders are deleted from the path "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default" 
      1. 'Cache\*',
      2. 'Cookies',
      3. 'Cookies-Journal',
      4. 'Media Cache',
      5. 'Cache2\entries\*'

      .INPUTS
      The following function doesn't take any inputs.

      .OUTPUTS
      Output :-

      VERBOSE: Closing current Chrome application
      VERBOSE: Chrome cache cookies cleared
  #>


  [CmdletBinding()]
  param (
            
  )
        
  begin {
            
    $chrome = 'chrome'
    if ($null -ne (get-process -name $chrome -erroraction SilentlyContinue)) {
      $null = & "$env:windir\system32\taskkill.exe" /F /IM 'chrome.exe'   
      Write-verbose -Message 'Closing current Chrome application' -Verbose
    }
    Start-Sleep -Seconds 2
  }
        
  process {
    $Items = @(
      'Cache\*',
      'Cookies',
      'Cookies-Journal',
      'Media Cache',
      'Cache2\entries\*'
    )
    $Folder = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default"
    $Items | ForEach-Object { 
      if (Test-Path -Path ('{0}\{1}' -f $Folder, $_)) {
        Remove-Item -force -Path ('{0}\{1}' -f $Folder, $_) 
      }
    }
  }
        
  end {
    Write-verbose -Message 'Chrome cache cookies cleared' -verbose
    Write-verbose -Message 'Launching Chrome...' -Verbose
    Start-Process $chrome
  }
}

     
     
# 3. Zscalar installed and running check .pac file - zscalar up and running can be checked and .pac files can be checked using autoconfig registry in internet settings path.

function get-ZscalerStatus {
  <#
      .SYNOPSIS
      Checks the status of Zscaler services.

      .DESCRIPTION
      The following functions checks the Status of all three services are checked and if any of the service is found in stopped state , restart it.

      .EXAMPLE
      get-ZscalerStatus
      Status of all three services are checked and if any of the service is found in stopped state , restart it.

      .NOTES
      
      Zscaler services:- 'zsaservice','zsatunnel','zsatraymanager'

      .INPUTS
      Function doesn't take any inputs.

      .OUTPUTS
      Output:-

      VERBOSE: Checking Zscalar services...
      VERBOSE: zsaservice is running
      VERBOSE: zsatunnel is running
      VERBOSE: zsatraymanager is running
      VERBOSE: All Zscaler services are running
  #>


  [CmdletBinding()]
  param (
        
  )
    
  begin {
    Write-Verbose -Message 'Checking Zscalar services...' -Verbose
    Start-Sleep -Seconds 2
  }
    
  process {
    try {
      foreach ($service in $zsaservices) {
        if((Get-Service -Name $service).Status -eq 'running'){
          Write-Verbose -Message ('{0} is running' -f $service) -Verbose
        }
        else {
          start-service -name $service
          Write-Verbose -Message ('{0} was stopped, restarting the service now' -f $service) -Verbose
        }
      }
    }
    catch {
      $issue=$($Error[0].exception.message)
      Write-Verbose -Message $issue -Verbose
      break
    }
  }
    
  end {
    Write-verbose -message 'All Zscaler services are running' -verbose
  }
}


#4. Check genesys app - whether it's installed or not and services up and running (app is in software center)(install genesys software - pop up)
function Get-InstalledSoftware
	{
    <#
    .SYNOPSIS
    Get all installed software with DisplayName, Publisher and UninstallString
                 
    .DESCRIPTION         
    Get all installed software with DisplayName, Publisher and UninstallString from a local or remote computer. The result will also include the InstallLocation and the InstallDate. To reduce the results, you can use the parameter "-Search *PRODUCTNAME*".
                                 
    .EXAMPLE
    Get-InstalledSoftware
       
    .EXAMPLE
    Get-InstalledSoftware -Search "*chrome*"
	  DisplayName     : Google Chrome
	  Publisher       : Google Inc.
	  UninstallString : "C:\Program Files (x86)\Google\Chrome\Application\51.0.2704.103\Installer\setup.exe" --uninstall --multi-install --chrome --system-level
	  InstallLocation : C:\Program Files (x86)\Google\Chrome\Application
	  InstallDate     : 20160506
    .EXAMPLE
    Get-InstalledSoftware -Search "*firefox*" -ComputerName TEST-PC-01  
	
    DisplayName     : Mozilla Firefox 47.0.1 (x86 de)
    Publisher       : Mozilla
    UninstallString : "C:\Program Files (x86)\Mozilla Firefox\uninstall\helper.exe"
    InstallLocation : C:\Program Files (x86)\Mozilla Firefox
    InstallDate     :
    
    #>
  
	param(
		[Parameter(
			Position=0)]
		[String]$Search,

		[Parameter(
			Position=1)]
		[String]$ComputerName = $env:COMPUTERNAME,

		[Parameter(
			Position=2)]
		[System.Management.Automation.PSCredential]
		[System.Management.Automation.CredentialAttribute()]
		$Credential
	)

	Begin{
		$LocalAddress = @('127.0.0.1','localhost','.',"$($env:COMPUTERNAME)")

		[System.Management.Automation.ScriptBlock]$ScriptBlock = {
			# Location where all entrys for installed software should be stored
			return Get-ChildItem -Path  'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall', 'HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall' | Get-ItemProperty | Select-Object -Property DisplayName, Publisher, UninstallString, InstallLocation, InstallDate
		}
	}

	Process{
		if($LocalAddress -contains $ComputerName)
		{			
			$Strings = Invoke-Command -ScriptBlock $ScriptBlock -ArgumentList $Search            
		}
		else
		{
			if(Test-Connection -ComputerName $ComputerName -Count 2 -Quiet)
			{
				try {
					if($PSBoundParameters.ContainsKey('Credential'))
					{
						$Strings = Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $ComputerName -ArgumentList $Search -Credential $Credential -ErrorAction Stop
					}
					else
					{					    
						$Strings = Invoke-Command -ScriptBlock $ScriptBlock -ComputerName $ComputerName -ArgumentList $Search -ErrorAction Stop
					}
				}
				catch {
					throw 
				}
			}
			else 
			{				
				throw ('""{0}"" is not reachable via ICMP!' -f $ComputerName)
			}
		}

		foreach($String in $Strings)
		{
			# Check for each entry if data exists
			if((-not([String]::IsNullOrEmpty($String.DisplayName))) -and (-not([String]::IsNullOrEmpty($String.UninstallString))))
			{
				# Search (only if parameter is used)
				if((-not($PSBoundParameters.ContainsKey('Search'))) -or (($PSBoundParameters.ContainsKey('Search') -and ($String.DisplayName -like $Search))))
				{                   
					[pscustomobject] @{
						DisplayName = $String.DisplayName
						Publisher = $String.Publisher
						UninstallString = $String.UninstallString
						InstallLocation = $String.InstallLocation
						InstallDate = $String.InstallDate
					}
				}   
			}
		}
	}

	End{
		
	}
}


 
 
#Main
  if(!(Test-Path -Path $LogFolder)){
  new-item -Path $LogFolder -ItemType Directory -Force
  }

  foreach ($software in $softwares) {
    if(Get-InstalledSoftware -search $software){
      Write-verbose -Message ('{0} is installed' -f $software) -Verbose
    }
    else {
      Write-verbose -Message ('{0} is not installed, please install the software first then continue..' -f $software) -Verbose
      Write-verbose -Message 'Exiting Script..GoodBye'
      break
    }
  }
  
  if($pacvalue -eq (Get-ItemPropertyValue -Path $pacreg -Name $pacname)){
    Write-Verbose -Message ('{0} exists' -f $pacvalue) -verbose
  }
  else{
    Write-Verbose -Message 'Either the Pac Value does not exist or its value is not correct' -Verbose
  }
  
  Get-PulseStatus -pulsestatus $pulsesecureadapter
  Remove-cacheCookiesChrome
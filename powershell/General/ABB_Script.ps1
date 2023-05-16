###########################################################################################################################################
#   Author :- Deepak Gautam                                                                                                               #
#   Email :- deepakgautam139@gmail.com                                                                                                        #
#   Date :- 17-Sept-2021                                                                                                                  #
#   Description :- Script is to automate the manual checks done by ABB team for Windows VM readiness.                                     #
###########################################################################################################################################


Write-host '
     #####################################################################################
     #                                                                                   #
     #              Welcome to the command line utility for ABB Windows VM Readiness     #
     #                                                                                   #
     #####################################################################################' 

     Start-Sleep -Seconds 1

#Functions

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

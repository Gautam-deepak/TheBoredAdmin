##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepak.gautam@hpe.com                                                                                           #
#   Date :- 20-May-2022                                                                                                      #
#   Description :- Script is to Patch windows servers using Task Schedular                                                   #
##############################################################################################################################

<# 
    Bugs:- 

    1. History file is created just after reboot but it shouldn't be. It is created twice , but it should only 
    be created at the end of it. - Fixed 
    
#>
<#
    Improvement :- 

    1. Update logic for get-wuhistory with current running time of script instead of minus 1 days. - Fixed
    2. Reboot is required before installation - Fixed 
    3. Script won't see the patches which are not downloaded. -pending
    4. When script execution stops, remote machine would wait endlessly - Fixed

#> 


<#PSScriptInfo

.VERSION 1.0.0

.GUID e38ddcb7-5fa9-4535-b2c3-5b9876b5d6aa

.AUTHOR DeepakGautam139@gmail.com

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


#Requires -Module @{ModuleName = 'PSWindowsUpdate'; ModuleVersion = '2.2.0.2'}

<# 

.DESCRIPTION 

 Script is to Patch windows servers using Task Schedular

 #> 

#variables

If(!(Test-path -Path $env:HOMEDRIVE\temp)){$null = New-Item -Name Temp -Path $env:HOMEDRIVE\ -ItemType Directory}

$CPPostRebootTask = 'CPPostReboottask'

$script:scriptPath = "$env:windir\system32\auto_patch_local.ps1"

$scriptdirectory = "$env:HOMEDRIVE\temp\"

$logFile = "C:\temp\$($env:COMPUTERNAME)_WindowsUpdate.log"

$winupdatelog="$env:HOMEDRIVE\temp\WindowsUpdate.txt"

$ErrorActionPreference='stop'

$script:lastreboottime=Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property LastBootUpTime -ExpandProperty lastbootuptime

$IPAddress=((& "$env:windir\system32\ipconfig.exe" | & "$env:windir\system32\findstr.exe" [0-9].\.)[0]).Split()[-1]  

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
        [parameter(Mandatory=$true,HelpMessage='Add help message for user')][string]$message
    )
    if( $? -eq $true ) {
        $messagefinal=$message+'- success'
        Write-log -level INFO -message $messagefinal
	
    } else {
        $messagefinal=$message+'- failed'
        Write-log -level ERROR -message $messagefinal
    }
}

Function Invoke-Wsuscheckin{
  <#
      .SYNOPSIS
      Describe purpose of "Invoke-Wsuscheckin" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      Invoke-Wsuscheckin
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Invoke-Wsuscheckin

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>



    Start-Service -Name wuauserv -Verbose 
    
    $updateSession = new-object -ComObject 'Microsoft.Update.Session'

    $updates=$updateSession.CreateupdateSearcher().Search('IsHidden=0 and IsInstalled=0').Updates

    Write-log -message 'Waiting 10 seconds for SyncUpdates webservice to complete to add to the wuauserv queue so that it can be reported on'
    Start-sleep -seconds 10
    
       # Now that the system is told it CAN report in, run every permutation of commands to actually trigger the report in operation
       & "$env:windir\system32\wuauclt.exe" /detectnow
       (New-Object -ComObject Microsoft.Update.AutoUpdate).DetectNow()
       & "$env:windir\system32\wuauclt.exe" /reportnow
       & "$env:windir\system32\usoclient.exe" startscan
    write-log -message 'Force sync to Wsus - success'
 }
 
Function Invoke-updates{
  <#
      .SYNOPSIS
      Describe purpose of "Invoke-updates" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      Invoke-updates
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Invoke-updates

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>

    try {
        # Searching for Windows Update
        $UpdateSession = New-Object -ComObject Microsoft.Update.Session
        $UpdateSearcher = $UpdateSession.CreateupdateSearcher()
        $Updates = @($UpdateSearcher.Search('IsHidden=0 and IsInstalled=0').Updates)
        if($updates.count -eq 0){
            write-log -level INFO -message 'No updates found'
        }
        else{
        write-log -level INFO -message 'Found Pending Updates on the System'
        }
    }
    catch {
        write-log -message ('Error Happened while searching for Windows update :{0} : {1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
        Set-Content -Path $scriptdirectory\is_stopped.txt -Value 'yes'
        exit
    }

    try {

        # Import PSwindowsUpdate Module
        Import-Module -Name PSWindowsUpdate
        Get-status -message 'Import PsWindowsUpdate '

        # Last Reboot Time  
        
        write-log -message ('Last Reboot Time : {0}' -f ($lastreboottime))
        #Set-Content -Path C:\Temp\reboot.txt -Value $lastreboottime -Force
    
        if(Get-WURebootStatus -Silent){
                
            # register schedule task forcefully so that the script runs at reboot
            $action = New-ScheduledTaskAction -Execute "${Env:WinDir}\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument ("-Command `"& '" + $scriptPath + "'`"")
            $trigger = New-ScheduledTaskTrigger -AtStartup
            $principal = New-ScheduledTaskPrincipal -UserID 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest
            $null = Register-ScheduledTask -TaskName $CPPostRebootTask -Action $action -Trigger $trigger -Principal $principal -Force
            Get-status -message 'Task Registration '

            # Reboot Required
            write-log -message 'A reboot is required on the system, updates will be installed after reboot'
            start-sleep -Seconds 5
            Restart-Computer -force
            Exit
        }

        # Checking Installer Status
        if(Get-WUInstallerStatus -Silent){
            if(Get-ScheduledTask -TaskName $CPPostRebootTask -ErrorAction Ignore){
                Write-log -message 'Windows Update Installer service is busy , hence adding 10 minutes in existing CPPostRebootTask'
                $triggertime = [String](Get-Date).AddMinutes('10').TimeOfDay.Hours  + ':' + [String](Get-Date).AddMinutes('10').TimeOfDay.Minutes
                $scheduled_time = New-ScheduledTaskTrigger -At $triggertime -Once
                $null = Set-ScheduledTask -TaskName $CPPostRebootTask -Trigger $scheduled_time
                Get-status -message 'Schedule Task Extension'
                Exit
            }
        }
        else{
    
            if ($Updates.Count -gt 0){
                # Pending updates
                write-log -message ('No. of Updates to install : {0}' -f $updates.Count)
                $title=$Updates | Select-Object -ExpandProperty Title
                $messages=foreach($item in $title){'Installing - ' + $item}
                Write-Log -message $messages
            
                Install-WindowsUpdate -AcceptAll -Install -IgnoreReboot -Confirm:$false -Verbose -ErrorAction stop | `
                Out-File -FilePath $winupdatelog -Force -Append
                Get-status -message 'Install-windowsupdate '
    
                if(Get-WURebootStatus -Silent){
                
                    # register schedule task forcefully so that the script runs at reboot
                    $action = New-ScheduledTaskAction -Execute "${Env:WinDir}\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument ("-Command `"& '" + $scriptPath + "'`"")
                    $trigger = New-ScheduledTaskTrigger -AtStartup
                    $principal = New-ScheduledTaskPrincipal -UserID 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest
                    $null = Register-ScheduledTask -TaskName $CPPostRebootTask -Action $action -Trigger $trigger -Principal $principal -Force
                    Get-status -message 'Task Registration '

                    # Reboot Required
                    write-log -message 'A reboot is required on the system, updates will be installed after reboot'
                    start-sleep -Seconds 10
                    Restart-Computer -force
                    exit
                }
                else{
                # remove script from running at startup
                    if(Get-ScheduledTask -TaskName $CPPostRebootTask -ErrorAction Ignore){
                        Unregister-ScheduledTask -TaskName $CPPostRebootTask -Confirm:$false -ErrorAction SilentlyContinue
                        Get-status -message 'Unregistering Schedule Task CPPostRebootTask'
                        write-log -message 'Updates installed successfully, no reboot required'
                    }                
                }
            }
            else
            {
                # remove script from running at startup
                if(Get-ScheduledTask -TaskName $CPPostRebootTask -ErrorAction Ignore){
                    Unregister-ScheduledTask -TaskName $CPPostRebootTask -Confirm:$false -ErrorAction SilentlyContinue
                    Get-status -message 'Unregistering Schedule Task CPPostRebootTask'
                    write-log -message 'Updates installed successfully, no reboot required'
                }
            }
        }
    }
    catch {
      Set-Content -Path $scriptdirectory\is_stopped.txt -Value 'yes'
      write-log -message ('Update Installation Error:{0} :{1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
      exit
    }
}

Function get-history{
  <#
      .SYNOPSIS
      Describe purpose of "get-history" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      get-history
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online get-history

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


  try {
    
    # Creating the final file to be imported to source server
    
    Get-wuhistory -MaxDate (get-date).AddDays(-1) | Select-Object -Property ComputerName,result,date,title,`
    @{n='Last Reboot Time';e={$lastreboottime}},@{n='IPAddress';e={$IPAddress}} | `
    Export-Csv -Path C:\Temp\$($env:computername)-history.csv -Force -NoTypeInformation
    Get-status -message 'Exporting History to CSV on Local Drive'

  }
  catch {
    Set-Content -Path $scriptdirectory\is_stopped.txt -Value 'yes'
    write-log -message ('Error Happened while exporting history to destination :{0} : {1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
    exit
    
  }
}

# Main Script

Remove-Item -Path $scriptdirectory\is_stopped.txt -Force -ErrorAction silentlycontinue
Invoke-updates
Get-History
Invoke-Wsuscheckin
Remove-Item -Path $scriptdirectory\is_stopped.txt -Force -ErrorAction silentlycontinue




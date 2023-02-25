#variables

If(!(Test-path -Path $env:HOMEDRIVE\temp)){New-Item -Name Temp -Path $env:HOMEDRIVE\ -ItemType Directory | out-null}
If(!(Test-path -Path $env:HOMEDRIVE\temp\uninstall.txt)){
    get-wmiobject -class win32_quickfixengineering | Where-Object {$_.installedon -gt $(get-date).AddDays(-60)} | `
    Select-Object -Property hotfixid -ExpandProperty hotfixID | Set-Content -Path C:\temp\uninstall.txt -force
}

$CPPostRebootTask = 'CPPostReboottask'

$Global:scriptPath = "C:\windows\system32\undopatching.ps1"

$logFile = "C:\temp\$($env:COMPUTERNAME)_WindowsUpdate.log"

$winupdatelog="$env:HOMEDRIVE\temp\WindowsUpdate.txt"

$ErrorActionPreference='stop'

$Global:lastreboottime=Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property LastBootUpTime -ExpandProperty lastbootuptime

$IPAddress=((ipconfig | findstr [0-9].\.)[0]).Split()[-1]  

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
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO","WARN","ERROR")]
        [string] $level = "INFO"
    )

    # Create timestamp
    $timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")

    # Append content to log file
    foreach($message in $messages){
    Add-Content -Path $logFile -Value "$timestamp [$level] - $message"
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
Function Invoke-uninstallupdates{
  
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
            Register-ScheduledTask -TaskName $CPPostRebootTask -Action $action -Trigger $trigger -Principal $principal -Force | out-null
            Get-status -message 'Task Registration '

            # Reboot Required
            write-log -message 'A reboot is required on the system, updates will be uninstalled after reboot'
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
                Set-ScheduledTask -TaskName $CPPostRebootTask -Trigger $scheduled_time | out-null
                Get-status -message 'Schedule Task Extension'
                Exit
            }
        }
        else{
            $KBs=Get-content -Path C:\temp\uninstall.txt -Force
            if ($KBs.Count -gt 0){
                # Pending updates
                write-log -message ('No. of Updates to uninstall : {0}' -f $KBs.Count)
            
                Foreach($kb in $KBs){
                    Uninstall-WindowsUpdate -KBArticleID $kb -IgnoreReboot -Confirm:$false -Verbose -ErrorAction Stop | `
                    Out-File -FilePath $winupdatelog -Force -Append
                    Get-status -message ('UninInstall-windowsupdate {0}' -f $kb)
                    $uninstall_file=Get-content -Path C:\temp\uninstall.txt 
                    $Uninstall_file | Where-Object {$_ -notmatch $kb} | Set-Content -Path C:\temp\uninstall.txt -Force
                    
                    if(Get-WURebootStatus -Silent){
                
                        # register schedule task forcefully so that the script runs at reboot
                        $action = New-ScheduledTaskAction -Execute "${Env:WinDir}\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument ("-Command `"& '" + $scriptPath + "'`"")
                        $trigger = New-ScheduledTaskTrigger -AtStartup
                        $principal = New-ScheduledTaskPrincipal -UserID 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest
                        Register-ScheduledTask -TaskName $CPPostRebootTask -Action $action -Trigger $trigger -Principal $principal -Force | out-null
                        Get-status -message 'Task Registration '

                        # Reboot Required
                        write-log -message 'A reboot is required on the system, updates will be uninstalled after reboot'
                        start-sleep -Seconds 5
                        Restart-Computer -force
                        exit
                    }
                    else{
                    # remove script from running at startup
                        if(Get-ScheduledTask -TaskName $CPPostRebootTask -ErrorAction Ignore){
                            Unregister-ScheduledTask -TaskName $CPPostRebootTask -Confirm:$false -ErrorAction SilentlyContinue
                            Get-status -message 'Unregistering Schedule Task CPPostRebootTask'
                            write-log -message 'Updates uninstalled successfully, no reboot required'
                        }                
                    }
                }
            }
            else
            {
                # remove script from running at startup
                if(Get-ScheduledTask -TaskName $CPPostRebootTask -ErrorAction Ignore){
                    Unregister-ScheduledTask -TaskName $CPPostRebootTask -Confirm:$false -ErrorAction SilentlyContinue
                    Get-status -message 'Unregistering Schedule Task CPPostRebootTask'
                    write-log -message 'Updates uninstalled successfully, no reboot required'
                }
            }
        }
  }
  catch {
    write-log -message ('Update UnInstallation Error:{0} :{1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
  }
}

# Main Script

Invoke-uninstallupdates
Remove-Item -Path $scriptPath\uninstall.txt -Force





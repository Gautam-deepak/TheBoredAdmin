<# 

Function is to deploy the pre-requisites of windows patching automation
    1. Deploy the PSWindowsUpdate Module
    2. Deploy the Patching schedule task 
    3. Deploy the Auto_patch_local.ps1 script

#>

param(
        [Parameter(Mandatory=$true,HelpMessage='Add help message for user')][string]$computerfilepath
        )
        
    $computers=get-content $computerfilepath

Function set-autopatchprereq {
    param(
        [Parameter(Mandatory=$true,HelpMessage='Add help message for user')][string[]]$computers
        )
        
    
    $computers | ForEach-Object -parallel {
        
    If(test-connection -ComputerName $_ -Count 1 -Quiet){
        Try {
            # Copying PSWindowUpdate Module 
            Copy-Item -Path "$env:HOMEDRIVE\temp\PSWindowsUpdate" -Recurse -Destination `
            ('\\{0}\c$\windows\system32\WindowsPowerShell\v1.0\Modules\' -f $_) -Force -ErrorAction stop
                    
            # Copying Local Script 
            Copy-Item -Path "$env:HOMEDRIVE\temp\auto_patch_local.ps1" -Destination `
            ('\\{0}\c$\windows\system32\' -f $_) -Force -ErrorAction stop
                
            # Creating schedule task 
            Invoke-Command -ComputerName $_ -ScriptBlock {
                # register schedule task forcefully so that the script runs at reboot
                $scriptPath="$env:windir\system32\auto_patch_local.ps1"
                $task='Patching'
                $description='Patching Automation Task (Owned and Managed by Wintel HPE)'
                $action = New-ScheduledTaskAction -Execute "${Env:WinDir}\System32\WindowsPowerShell\v1.0\powershell.exe" `
                    -Argument ("-Command `"& '" + $scriptPath + "'`"")
                    $trigger = New-ScheduledTaskTrigger -Once -At $(get-date)
                    $principal = New-ScheduledTaskPrincipal -UserID 'NT AUTHORITY\SYSTEM' -LogonType ServiceAccount -RunLevel Highest
                    $null = Register-ScheduledTask -TaskName $task -Description $description -Action $action -Trigger $trigger -Principal $principal -Force
                } -ErrorAction stop
                
                $status = 'Success'   
                $issue='No Issue'
    }
        Catch {
            $status = 'Failed'
            $issue=$error[0].Exception.Message
                    
        }
        Finally {
            $ErrorActionPreference = 'Continue'
            $error.Clear()
        }
    }
    else{
        $status = 'Unreachable'
        $Issue=('Unable to connect to {0}' -f $_)
    }
            
    $output=[pscustomobject]@{
        'Computer'=$_
        'Status'=$status
        'Error'=$issue
        }
    $output    
    } -throttlelimit 100 -AsJob | receive-job -Wait -AutoRemoveJob
}

set-autopatchprereq -computers $computers

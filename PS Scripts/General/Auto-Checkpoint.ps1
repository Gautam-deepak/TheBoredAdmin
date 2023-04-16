<#
1. The script starts by checking for the existence of the log directory in the HOMEDRIVE environment variable.
If it does not exist, it creates it. It then sets the path for the log file using the COMPUTERNAME environment variable.

2. The script then gets all VMs and selects only those that are currently running.

3. The script defines two functions: write-mylog and get-status.

4. The write-mylog function is used to append log messages to a specified file with a timestamp, severity level (INFO, WARN, or ERROR), and message.

5. The get-status function takes a message parameter and determines whether the previous command succeeded or failed
based on the success of the last command.

6. The main part of the script is the set-preparevm function, which prepares VMs to take checkpoints.

7. In Section-01 of the set-preparevm function, it prints the running status of all VMs.

8. In Section-02 of the set-preparevm function, it sets the running VMs to take production checkpoint only.
It uses the get-status function to confirm that the VMs were set to take production checkpoint.

9. The script then creates a snapshot chain report.

10. Finally, the script schedules the checkpoints to be taken twice a day, deleting the previous one before taking a new one.
#>

Set-ExecutionPolicy Bypass -Scope Process
If(!(Test-path -Path $env:HOMEDRIVE\logs)){$null = New-Item -Name logs -Path $env:HOMEDRIVE\ -ItemType Directory}
$logFile = "C:\logs\$($env:COMPUTERNAME)_hyperv.log"
$date=get-date
$All_VMs=Get-VM
$excl_servers="GL-DC-01","GL-DC-02","GL-DISCOVERY","GL-GMSMID","GL-MONITOR01","GL-RDA01","GL-Solarwind","GL-SQLDB01","GL-Jump01","GL-SSMC"
#"GL-FTP01","GL-Jump-01","GL-Jump-02","gl-meteringserver","GL-SPOG01","GL-SPOG02","GL-SSMC"
$Running_VMs=$All_VMs | where-object {$excl_servers -notcontains $_.name} | Where-Object {$_.State -eq "Running"} | `
Select-Object name -ExpandProperty name
$ErrorActionPreference="Stop"

Function write-mylog {
    <#
    .SYNOPSIS
    This function appends log messages to a file with a timestamp, level, and message.

    .DESCRIPTION
    The write-mylog function appends log messages to a specified file with a timestamp, level (INFO, WARN, or ERROR), and message.

    .PARAMETER messages
    Specifies one or more messages to be logged.

    .PARAMETER level
    Specifies the severity level of the logged message. Valid values are INFO (default), WARN, and ERROR.

    .EXAMPLE
    write-mylog -messages "This is an INFO message"
    write-mylog -messages "This is a WARNING message" -level WARN
    write-mylog -messages "This is an ERROR message" -level ERROR

    .NOTES
    None.

    .LINK
    None.

    .INPUTS
    None.

    .OUTPUTS
    None.
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
    }
}

Function Get-status{
    <#
    .SYNOPSIS
    Describes whether the operation was successful or not.

    .DESCRIPTION
    This function takes a message parameter and determines whether the operation succeeded or failed based on the success of the last command.

    .PARAMETER message
    Specifies the message to display in the log.

    .EXAMPLE
    Get-status -message "Operation completed"
    Logs the message "Operation completed - success" if the previous command succeeded, otherwise logs "Operation completed - failed".

    .NOTES
    This function is used to log the status of the previous command.

    .LINK
    N/A

    .INPUTS
    This function does not accept input from the pipeline.

    .OUTPUTS
    This function does not output anything to the pipeline. It logs the result of the operation to the log.

    #>

    param(
        [parameter(Mandatory=$true,HelpMessage='Add help message for user')][string]$message
    )
    if( $? -eq $true ) {
        $messagefinal=$message+'- success'
        write-mylog -level INFO -message $messagefinal
    }
    else{
        $messagefinal=$message+'- failed'
        write-mylog -level ERROR -message $messagefinal
    }
}


# Main


function set-preparevm {
    <#
    .SYNOPSIS
    Sets the VMs to take production checkpoint only, as part of the process to prepare them for taking checkpoints.

    .DESCRIPTION
    The set-preparevm function prepares VMs to take checkpoints. In Section-01, it prints the running status of all VMs.
    In Section-02, it sets the running VMs to take production checkpoint only. It uses the Get-status function to confirm that
    the VMs were set to take production checkpoint.

    .PARAMETER None
    This function does not accept any parameters.

    .EXAMPLE
    set-preparevm
    This command prepares VMs to take checkpoints.

    .NOTES
    This function requires the Get-status and Write-mylog functions.

    .LINK
    https://docs.microsoft.com/en-us/powershell/module/hyper-v/set-vm
    https://docs.microsoft.com/en-us/powershell/module/hyper-v/get-vm
    https://docs.microsoft.com/en-us/powershell/module/hyper-v/checkpoint-vm
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-host
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/write-warning
    https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about_functions

    .INPUTS
    None. You cannot pipe objects to this function.

    .OUTPUTS
    None. The function does not return any output, but logs the output to the log file using the Write-mylog function.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
    )

    begin {
        write-mylog -messages "--------------------------------------------------------------"
        write-mylog -messages "Preparing VMs to take checkpoints"
    }

    process {
        try {
            # Section-01

            write-mylog -messages "--------------------------------------------------------------"
            write-mylog -messages "Section-01 - Printing VM running status"

            foreach($All_VM in $All_VMs){
                write-mylog -messages "The VM $(($All_VM).name) is in $(($All_VM).state) and $(($All_VM).status)"
            }

            write-mylog -messages "Section-01 - Finished Printing VM running status"

            write-mylog -messages "--------------------------------------------------------------"

            write-mylog -messages "Section-02 - Setting VMs to take production checkpoint only"

            Foreach($running_vm in $Running_VMs){
                Set-VM -Name $running_vm -CheckpointType ProductionOnly
                Get-status -message "Set $($running_vm) to take production checkpoint"
            }
            write-mylog -messages "Section-02 - Finished Setting VMs to take production checkpoint only"

            write-mylog -messages "--------------------------------------------------------------"

        }
        catch {
            write-mylog -level ERROR -messages "$($Error[0].exception.message) happened"
        }
    }

    end {
        write-mylog -messages "--------------------------------------------------------------"
        write-mylog -messages "Finished Preparing VMs to take checkpoints"
    }
}
function Set-VMcheckpoint {
    <#
    .SYNOPSIS
    Creates a checkpoint for a set of running virtual machines, removes any extra checkpoints, and logs the operation.

    .DESCRIPTION
    This function takes an array of running virtual machine names as input, creates a checkpoint for each virtual machine, and removes any extra checkpoints. It also logs the operation in a log file.

    .PARAMETER runningVMs
    An array of running virtual machine names for which checkpoints need to be taken.

    .EXAMPLE
    Set-VMcheckpoint -runningVMs "VM1","VM2","VM3"
    Creates checkpoints for the running virtual machines "VM1", "VM2", and "VM3".

    .NOTES
    The function requires the "Checkpoint-VM" and "Remove-VMCheckpoint" cmdlets to be available on the system.

    .LINK
    https://docs.microsoft.com/en-us/powershell/module/hyper-v/checkpoint-vm
    https://docs.microsoft.com/en-us/powershell/module/hyper-v/remove-vmcheckpoint

    .INPUTS
    An array of running virtual machine names.

    .OUTPUTS
    None. The function writes the result to a log file.
    #>

    [CmdletBinding(SupportsShouldProcess)]
    param (
        [parameter(Mandatory=$true,HelpMessage='All running VMs')][string[]]$runningVMs
    )

    begin {
        write-mylog -messages "--------------------------------------------------------------"
        write-mylog -messages "Section-03 Starting checkpoint execution for date $($date)"
    }

    process {
        foreach($running_vm in $Running_VMs){
            try {
                $total_checkpoint=Get-VMCheckpoint -vmname $running_vm
                if(($total_checkpoint).count -lt 2){
                    Checkpoint-VM -name $running_vm -snapshotname $date
                    write-mylog -messages "Successfully taken checkpoint of $($running_vm)"
                }
                else{
                    write-mylog -messages "total checkpoints available for $($running_vm) are $(($total_checkpoint).count)"
                    write-mylog -messages "$(($total_checkpoint).count -1 ) checkpoints of $($running_vm) will be removed"
                    while((Get-VMCheckpoint -vmname $running_vm).count -gt 1) {
                        $OldestSnapshot = Get-VMCheckpoint -vmname $running_vm | Sort-Object -Property CreationTime | Select-Object -First 1
                        $oldestsnapshot | Remove-VMCheckpoint
                        start-sleep -Seconds 10
                        write-mylog -messages "Removing extra checkpoint $($OldestSnapshot.Name) of VM $($OldestSnapshot.Vmname)"
                    }
                    Checkpoint-VM -name $running_vm -snapshotname $date
                    write-mylog -messages "Created another checkpoint of $running_vm"
                }
            }
            catch {
                write-mylog -level ERROR -messages "Unable to take checkpoint of $running_vm with error $($Error[0].exception.message)"
            }
        }
    }

    end {
        write-mylog -messages "Section-03 Finished checkpoint execution for date $($date)"
        write-mylog -messages "--------------------------------------------------------------"
    }
}

# Main
write-mylog -messages "=============================================================="
write-mylog -messages "Starting script execution for date $($date)"
set-preparevm
if(!$Running_VMs){
    write-mylog -messages "There are no running VMs , no checkpoint taken."
}
else{
    Set-VMcheckpoint -runningVMs $Running_VMs
}
write-mylog -messages "Finished script execution for date $($date)"
write-mylog -messages "=============================================================="
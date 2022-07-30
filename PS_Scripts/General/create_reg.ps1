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
            } -ArgumentList "HKLM:\SYSTEM\CurrentControlSet\Services\DNS\Parameters","TcpReceivePacketSize","0xFF00" # creating registry on remote computer
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

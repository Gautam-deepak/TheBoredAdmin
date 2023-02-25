#script to remotely restart the server
$Computers = Get-Content "C:\computerlist.txt"
$ErrorActionPreference="Stop"

$results = foreach ($computer in $computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {
           
            Restart-Computer -Wait -For PowerShell -ComputerName $_ -Credential $credential -Timeout 600 -Delay 5 -Force;
            $uptime=[System.Management.ManagementDateTimeconverter]::ToDateTime($(Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem  | Select-Object -ExpandProperty LastBootUpTime))
            $status = "Success"
            $issue="No Error"

        } Catch {
            $uptime="unknown"
            $status = "Failed"
            $issue=$($Error[0].exception.message)

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        $uptime="unknown"
        $status = "Unreachable"
        $issue="Destination host is not reachable"
    }
    
    [pscustomobject]@{
        'Computer'=$computer
        'Status'=$status
        'Error'=$issue
        'Uptime'=$uptime
    }
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force

param (
    [Parameter()]
    [string]
    $filepath
)

$computers=Get-Content -Path $filepath
$ErrorActionPreference="stop"
$temppath="C:\temp"

# Main

if(!(Test-Path $temppath)){
    New-Item -Path "C:\" -Name "temp" -Force -ItemType Directory | Out-Null
}

# get list of installed application and their versions from list of servers

$results = foreach ($computer in $computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {
           
            $tempresult=Get-WmiObject -class win32_product -ComputerName $computer | Select-Object pscomputername,name,version

            $tempresult | Export-Csv -Path C:\temp\success_result.csv -notypeinformation -Force -Append

            $status = "Success"
            $issue="No Error"

        } Catch {
            
            $status = "Failed"
            $issue=$($Error[0].exception.message)

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        
        $status = "Unreachable"
        $issue="Destination host is not reachable"
    }
    
    [pscustomobject]@{
        'Computer'=$computer
        'Status'=$status
        'Error'=$issue
        
    }
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force
param(
    [string]$filepath
)


$Computers = Get-Content -Path $filepath
$ErrorActionPreference="Stop"

$results = foreach ($computer in $computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {
           
            Invoke-Command -ComputerName $Computer.Trim() -ScriptBlock {
            
            }
            
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
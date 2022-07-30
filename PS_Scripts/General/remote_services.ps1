$Computers = Get-Content "C:\computerlist.txt"
$ErrorActionPreference="Stop"

$results = foreach ($computer in $Computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {
           
            $agent=(Invoke-Command -ComputerName $Computer -ScriptBlock {
                (Get-Service -Name opsramp-agent).Status
            }).value
            $Shield=(Invoke-Command -ComputerName $Computer -ScriptBlock {
                (Get-Service -Name opsramp-shield).Status
            }).value
            $opsramp_agent = $agent
            $opsramp_shield=$Shield
            $issue="No Error"

        } Catch {
            $opsramp_agent = "Failed"
            $opsramp_shield="Failed"
            $issue=$($Error[0].exception.message)

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        $opsramp_agent = "NA"
        $opsramp_shield="NA"
        $issue="Destination host is not reachable"
    }
    
    [pscustomobject]@{
        'Computer'=$computer
        'Opsramp_agent'=$opsramp_agent
        'Opsramp_shield'=$opsramp_shield
        'Error'=$issue
    }
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force



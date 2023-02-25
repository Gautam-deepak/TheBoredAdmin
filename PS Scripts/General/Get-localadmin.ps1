$Computers = Get-ADComputer -Filter * -Properties name,operatingsystem,enabled  | `
Where-Object {$_.operatingsystem -like "*server*" -and $_.enabled -eq $true} | `
Select-Object name -ExpandProperty name

$ErrorActionPreference="Stop"

$results = foreach ($computer in $Computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {
           
            $allmembers=Invoke-Command -ComputerName $Computer -ScriptBlock {
                #((Get-LocalGroupMember "administrators").name) -join ','
                (net localgroup administrators | `
                Where-Object {$_ -AND $_ -notmatch "command completed successfully"} | `
                Select-Object -skip 4) -join ','
            }
            $status = "Success"
            $issue="No Error"
            $members=$allmembers
            $group="Administrators"

        } Catch {

            $status = "Failed"
            $issue=$($Error[0].exception.message)
            $members="NA"
            $group="Administrators"

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        $status = "Unreachable"
        $issue="Destination host is not reachable"
        $members="NA"
        $group="Administrators"
    }
    
    [pscustomobject]@{
        'Computer'=$computer
        'Status'=$status
        'Error'=$issue
        'Members'=$members
        'Group'=$group
    }
}

$results | Export-Csv -path c:\results.csv -NoTypeInformation -Force

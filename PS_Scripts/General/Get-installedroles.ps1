$computers=Get-ADDomainController -Filter * | Select-Object hostname -ExpandProperty hostname


$ErrorActionPreference="Stop"

$results = foreach ($computer in $computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {

            $roles=Invoke-Command -computername $computer -ScriptBlock{ 
            (Get-WindowsFeature | Where-Object {$_.installed -eq $true -and $_.featuretype -eq "role" -and `
            $_.name -ne "AD-Domain-Services" `
            -and $_.name -ne "DNS"} | Select-Object Name -ExpandProperty Name) -join ","
            }
            $sites=get-addomaincontroller -Identity $computer | Select-Object -ExpandProperty site

            $status = "Success"
            $issue="No Error"
            $Role=$roles
            $Site=$sites

        } Catch {

            $status = "Failed"
            $issue=$($Error[0].exception.message)
            $Role="NA"
            $site="NA"
        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   

        $status = "Unreachable"
        $issue="Destination host is not reachable"
        $Role="NA"
        $site="NA"
    }

    [pscustomobject]@{
        'Computer'=$computer
        'Status'=$status
        'Issue'=$issue
        'AD Site'=$site
        'Roles'=$Role

    }
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force
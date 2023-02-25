$computers=Get-ADComputer -Filter * -Properties * | Where-Object {$_.operatingsystem -match "server" -and $_.enabled -eq $true} | `
Select-Object -Property Name -ExpandProperty name

$ErrorActionPreference="Stop"
$KB="KB5017316"

Import-Module -name ActiveDirectory

$results = foreach ($computer in $computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {
           
            if(!([string]::isnullorempty((Get-HotFix -ComputerName $computer -Id $KB)))){
                $KB_Status="Installed"
            }
            $version=Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computer | Select-Object caption -ExpandProperty caption
            $status = "Success"
            $issue="No Error"


        } 
        catch [System.ArgumentException]{
            $KB_Status="Not Installed"
            $version=Get-CimInstance -ClassName win32_operatingsystem -ComputerName $computer | Select-Object caption -ExpandProperty caption
            $status = "Success"
            $issue="No Error"
        }
        Catch {
            $KB_Status="NA"
            $version="NA"
            $status = "Failed"
            $issue=$($Error[0].exception.message)

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        $KB_Status="NA"
        $version="NA"
        $status = "Unreachable"
        $issue="Destination host is not reachable"
    }
    
    [pscustomobject]@{
        'Computer'=$computer
        'KB Install Status'=$KB_Status
        'OS'=$version
        'Status'=$status
        'Error'=$issue
        
    }
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force
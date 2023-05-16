$Domaincontrollers=Get-ADDomainController -Filter * | Select-Object name -ExpandProperty Name
function Invoke-DcDiag {
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string[]]$DomainControllers
    )
    Foreach ($DomainController in $DomainControllers){
    $result = dcdiag /s:$DomainController
    $result | select-string -pattern '\. (.*) \b(passed|failed)\b test (.*)' | ForEach-Object {
        $obj = @{
            TestName = $_.Matches.Groups[3].Value
            TestResult = $_.Matches.Groups[2].Value
            Entity = $_.Matches.Groups[1].Value
        }
        [pscustomobject]$obj
        }
    } 
}

$results=Invoke-DcDiag -DomainControllers $Domaincontrollers
$results | Export-Csv -Path C:\temp\dcdiag.csv -NoTypeInformation -Force


$Domaincontrollers=Get-ADDomainController -Filter * | Select-Object name -ExpandProperty Name
$results=$Domaincontrollers | ForEach-Object -Parallel {
    function Invoke-DcDiag {
        param(
            [Parameter(Mandatory=$false)]
            [ValidateNotNullOrEmpty()]
            [string]$DomainController=$env:COMPUTERNAME
        )
        $result = dcdiag /s:$DomainController
        $result | select-string -pattern '\. (.*) \b(passed|failed)\b test (.*)' | ForEach-Object {
            $obj = @{
                TestName = $_.Matches.Groups[3].Value
                TestResult = $_.Matches.Groups[2].Value
                Entity = $_.Matches.Groups[1].Value
            }
            [pscustomobject]$obj
            }
    }
    
    If (test-connection -ComputerName $_ -Count 1 -Quiet)
    {
        Try {
           Invoke-DcDiag -DomainController $_

        } Catch {
            Write-Output "Failure on $_"
        }
        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        Write-Output " $_ is unreachable"
    }
} -throttlelimit 100 -AsJob | Receive-Job -Wait -AutoRemoveJob

$results | export-csv -Path c:\Unreachable.csv -NoTypeInformation -Force
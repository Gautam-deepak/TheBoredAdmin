#variables

$css= "<style>"
$css= $css+ "BODY{ text-align: center; background-color:white;}"
$css= $css+ "TABLE{    font-family: 'Lucida Sans Unicode', 'Lucida Grande', Sans-Serif;font-size: 12px;margin: 10px;width: 100%;text-align: center;border-collapse: collapse;border-top: 7px solid #004466;border-bottom: 7px solid #004466;}"
$css= $css+ "TH{font-size: 13px;font-weight: normal;padding: 1px;background: #cceeff;border-right: 1px solid #004466;border-left: 1px solid #004466;color: #004466;}"
$css= $css+ "TD{padding: 1px;background: #e5f7ff;border-right: 1px solid #004466;border-left: 1px solid #004466;color: #669;hover:black;}"
$css= $css+  "TD:hover{ background-color:#004466;}"
$css= $css+ "</style>" 


function get-Result {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$result,

        [Parameter(Mandatory)]
        [string]$string

    )

    If($result -eq $true)
            {
            
                Write-Host $string successful
            
            }
        else {
                Write-host $string failed
            
            }
}

$Computers = Get-Content "C:\computerlist.txt"
$ErrorActionPreference="Stop"

$results = foreach ($computer in $Computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {
           
            Invoke-Command -ComputerName $Computer -ScriptBlock {
            
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



#Main
  
$StartDate = (get-date).adddays(-1)
 
$body = Get-WinEvent -FilterHashtable @{logname="Application"; starttime=$StartDate; ID="16394","1"} -ErrorAction SilentlyContinue
 
$body | ConvertTo-HTML -Head $css MachineName,ID,TimeCreated,Message > D:\LogAppView.html 
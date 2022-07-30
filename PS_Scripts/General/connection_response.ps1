##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepakgautam139@gmail.com                                                                                           #
#   Date :- 2-June-2021                                                                                                      #
#   Description :- Script is to check connectivity of remote servers                                                         #
##############################################################################################################################


# Variables

param (
        [Parameter(Mandatory)]
        [string] $serverlistpath, #Path where server list is stored

        [Parameter(Mandatory)]
        [string] $resultpath # Path where results will be published
       
        )

#variables

$ErrorActionPreference="silentlycontinue"
$WarningPreference="silentlycontinue"
$servers= Get-Content -path $serverlistpath # Getting content of servers list

Write-Host Total number of servers to check: $servers.count
# Main
 $result=@(foreach ($item in $servers) {
    
    Write-Host "Checking $item"

    if(Test-Connection -ComputerName $item -Count 1 -Quiet){
        $status=$True # Setting status to true if reachable
    }
    else {
        $status=$false # Setting status to false if not reachable
    }
    [pscustomobject]@{ # A custom object to store the results
        'Computer'=$item
        'Status'=$status
    }
})
Write-Host "Script finished - Publishing results"
Start-Sleep 2
$result | Export-Csv -NoTypeInformation -Path $resultpath -Force # Publishing results

 



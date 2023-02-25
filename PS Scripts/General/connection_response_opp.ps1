# Variables

$ErrorActionPreference="silentlycontinue"
$WarningPreference="silentlycontinue"
$servers= Get-Content -path D:\servers.txt # Give the path for text file which should contain list of servers to be checked 


# Main

$result=@(foreach ($item in $servers) {

    if(Invoke-Command -ComputerName $item -ScriptBlock { (Test-NetConnection -ComputerName "wsus_server" -Port "XXX" ).PingSucceeded}){
       
        write-output "$item,Connected"

    }
    else {

        write-output "$item,failure"

    }
})

Out-File -Path d:\results.csv -InputObject $result  # Provide out file Path

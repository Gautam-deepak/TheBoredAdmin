##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepak.gautam@hpe.com                                                                                           #
#   Date :- 05-Nov-2022                                                                                                      #
#   Description :- Check connectivity of remote servers using test-connection                                                #
##############################################################################################################################

<# 
test-connection sends Internet Control Message Protocol (ICMP) echo request packets, 
or pings, to one or more remote computers and returns the echo response replies
#>

param(
    [string]$filepath
)


$Computers = Get-Content -Path $filepath
$ErrorActionPreference="Stop"

$results = $computers | ForEach-Object -Parallel {
    Write-Host "Working on $_" -ForegroundColor "green"

    If (test-connection -ComputerName $_ -Count 1 -Quiet)
    {
        $status = "Success"   
    }
    else
    {   
        $status = "Unreachable"
    }
    
    [pscustomobject]@{
        'Source'=$env:COMPUTERNAME
        'Destination'=$_
        'Status'=$status
    }
} -ThrottleLimit 100 -AsJob | Receive-Job -Wait -AutoRemoveJob

$results | Export-Csv -NoTypeInformation -Path C:\temp\results.csv -Force
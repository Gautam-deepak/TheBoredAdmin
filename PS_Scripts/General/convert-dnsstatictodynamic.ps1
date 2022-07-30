# Convert DNS dynamic entries to static entries
$stopwatch=[System.Diagnostics.Stopwatch]::StartNew() # A stop watch to calculate time taken

# Variables
$csv=import-csv -Path "C:\temp\small.csv" 
[int]$i=0
$results = foreach ($item in $csv)
{
    Write-Host Working on $item.hostname

        Try {
           $entry=Get-DnsServerResourceRecord -Name $item.hostname -ZoneName "upl.com" -RRType "A"
           $IPinDNS=$entry.RecordData.IPv4Address.IPAddressToString

            if($null -eq $entry.timestamp){
                $status="static"
                if($IPinDNS -eq $item.IP){
                    $issue="IP is static and matches with csv"
                }
                else{
                    $issue="IP is static but DNS IP does not match IP in CSV"
                }
            }
           else {
                $status="dynamic"
                if ($item.IP -eq $IPinDNS){ 
                    $issue="IP is dynamic and matches with csv"
                    add-dnsserverresourcerecord -ZoneName upl.com -Name $item.hostname -A -IPv4Address $item.IP -Confirm:$false
                }
                else{
                    
                    $issue="IP is dynamic but DNS IP does not match IP in CSV"
                    
                }
                    
                }
            
        } Catch {
            
            $status="FAIL"
            $issue="DNS entry not found"
            $IPinDNS="N/A"

        }

        Finally{
            $Error.Clear()
        }
    
    [pscustomobject]@{
        'Computer'=$item.hostname
        'IP'=$item.IP
        'IP_DNS'=$IPinDNS
        'DNS_Status'=$status
        'Issue'=$issue
        
    }
    $i++
    Write-Progress -Activity "Performing Operation" -Status  ('At row {0} out of {1}' -f $i,$csv.length) -PercentComplete ($i/$csv.Length*100)
    
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force

$stopwatch.Stop()

Write-Host Time taken: $stopwatch.Elapsed.seconds
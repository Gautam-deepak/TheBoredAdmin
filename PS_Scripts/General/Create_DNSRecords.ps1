# Create DNS Host A and PTR records from csv file

$dnsrecords=Import-Csv -Path "C:\Users\Documents\dns.csv" 
$dnsrecordzone=$env:USERDNSDOMAIN
$ErrorActionPreference="stop"

$results=foreach ($dnsrecord in $dnsrecords) {
    try {
        Add-DnsServerResourceRecordA -name $dnsrecord.hostname.Trim() -ipv4address $dnsrecord.ip.Trim() -ZoneName $dnsrecordzone -CreatePtr
        $status = "Success"
        $issue= "None"
    }
    catch {
        $status = "Failed"
        $issue=$($Error[0].exception.message)
    }
    Finally {
        Write-Host "Hostname: $($dnsrecord.hostname) IP: $($dnsrecord.ip) Status: $status Issue: $issue"
        $Error.Clear()
    }
    [pscustomobject]@{
        'HostName'=$dnsrecord.hostname
        'Status'=$status
        'Error'=$issue
        
    }

}
$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force
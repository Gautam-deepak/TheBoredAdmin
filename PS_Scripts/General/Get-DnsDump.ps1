
$zone=@("$zone");

#$zone="novaprime.in"

$result=foreach($item in $zone){

    Get-DnsServerResourceRecord -ZoneName $item #-server $env:COMPUTERNAME
    
}

$final=foreach($item in $result){

[pscustomobject]@{
        'Hostname'   = $item.hostname
        'IPAddress'  = $item.RecordData.ipv4address.IPAddressToString
        'RecordType'= $item.recordtype
        'Timestamp'= $item.Timestamp
        'TTL'= $item.timetolive
    }
}

$testconnection=$final | Where-Object {$_.recordtype -eq "A"} | Format-Table

$results = foreach ($computer in $testconnection)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer.ipaddress -Count 1 -Quiet)
    {
        $status = "reachable"
        $issue= "None"
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

$date=(get-date).GetDateTimeFormats()[6]
$records = Get-DnsServerResourceRecord -ZoneName $env:USERDNSDOMAIN --rrtype "A"

$DNS_DUMP = foreach($record in $records){
    [pscustomobject]@{
        Hostname   = $record.hostname
        IPAddress  = $([system.version]($record.RecordData.ipv4address.IPAddressToString))
        Type=$record.RecordType
        Timestamp=$record.Timestamp
    }
}

$DNS_DUMP | sort-object ipaddress -Unique | Export-Csv -Path C:\DNS_Dump_$date.csv -NoTypeInformation -Force

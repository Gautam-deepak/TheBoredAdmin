# script is to continously check if an A record is reachable, and if not remove it from DNS
# This is a part of a DNS Host A records where round robin is configured for NFS Shares.

#variables
$scopes="r1-storage-01","r1-storage-02","r1-storage-03","r1-storage-04","r1-storage-05","r1-storage-06"
$domain="scality.abbvie.hpegms"
$policyname="LBPolicy"

#main
foreach($scope in $scopes){
    $pingoutput=(Test-NetConnection -ComputerName $($scope+"."+$domain) -WarningAction Ignore).PingSucceeded
    Write-Host "Ping Status of $($scope) : $($pingoutput)"
    $statusCode = Invoke-WebRequest -Uri http://$($scope+"."+$domain)/_/healthcheck/deep/ | ForEach-Object {$_.StatusCode}
    Write-Host "Health status of node $($scope) : $($statusCode)"
    if($pingoutput -eq $true -and $statusCode -eq 200){
        $scopestring+=$scope+"-"+"scope,2;"
        Write-Host "Added $($scope) in scope string"
    }
}
$finalscopestring= $scopestring.Remove($scopestring.LastIndexOf(";"))
Set-DnsServerQueryResolutionPolicy -Name $policyname -ZoneName $domain -ZoneScope $finalscopestring -PassThru
Clear-Variable scopestring
Clear-Variable finalscopestring

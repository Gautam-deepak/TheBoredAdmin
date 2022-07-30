Get-ADComputer -Filter * -Properties * | Where-Object {$_.operatingsystem -notlike "*server*"} | `
Select-Object name,distinguishedname,Enabled,canonicalname,operatingsystem,operatingsystemversion,`
@{N='LastLogon'; E={[DateTime]::FromFileTime($_.LastLogontimestamp)}} | `
Where-Object {$_.lastlogon -lt (get-date).adddays(-90)} | `
export-csv -Path c:\staleentries.csv -NoTypeInformation -Force


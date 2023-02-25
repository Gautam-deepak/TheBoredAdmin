$Servers = Get-Content -Path "C:\users\$env:username\desktop\servers.txt"
$Array = @()
 
Foreach($Server in $Servers)
{
    $DNSCheck = $null
    $Server = $Server.trim()
 
    $DNSCheck = ([System.Net.Dns]::GetHostByName(("$Server")))
 
    $Object = New-Object PSObject -Property ([ordered]@{ 
      
                "Server name"             = $Server
                "FQDN"                    = $DNSCheck.hostname
                "IP Address"              = $DNSCheck.AddressList[0]
 
    })
   
    # Add object to our array
    $Array += $Object
 
}
$Array
$Array | Export-Csv -Path C:\users\$env:username\desktop\results.csv -NoTypeInformation

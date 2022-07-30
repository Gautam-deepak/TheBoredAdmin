function add-route {
    [CmdletBinding()]
    param (
        
    )
    
    begin {
        Write-Host "Checking if pulse secure is connected"
        $pulsesecure=Get-NetAdapter | Where-Object {$_.InterfaceDescription -eq 'Juniper Networks Virtual Adapter'}
        if($null -eq $pulsesecure){
        Write-verbose -message 'Please connect Pulse Secure to continue' -Verbose
        Set-Location -Path "${env:CommonProgramFiles(x86)}\Pulse Secure\JamUI"
        .\Pulse.exe -show
    }
    
    process {
        if ((Get-NetIPAddress | Where-Object {$_.ipaddress -like "16.*"}).ipaddress) {
            Write-Host "Pulse secure connected...."
            $IP=(Get-NetIPConfiguration | Where-Object{$_.interfacedescription -eq "Juniper Networks Virtual Adapter"}).ipv4address.ipaddress
            route add 115.113.157.172 MASK 255.255.255.255 $IP
            Write-Host "Route Added..."
            }
            else {
                Write-host "Connect Pulse Secure first...."
            }
         
    }
    
    end {
        Write-Host "cleaning up----Goodbye..."
    }
}

# Main

add-route

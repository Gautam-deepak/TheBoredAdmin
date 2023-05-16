

# Requirements and feasibility :- 

# 1. Check VPN is connected or not - can be checked using Get-netadaptor command, then we can apply a wait loop and pop up pulse secure to connect before proceeding further.
    
$pulsesecure=Get-NetAdapter | Where-Object {$_.InterfaceDescription -eq "Juniper Networks Virtual Adapter"}
if($null -eq $pulsesecure){
Write-Host "Please connect Pulse Secure to continue"
throw
}
try {
    if($null -eq $pulsesecure){
        Write-Host "Please connect Pulse Secure to continue"
        Start-Sleep -Seconds 2    
        }
}
catch {
    
}


 
    $pulsesecure=Get-NetAdapter | Where-Object {$_.InterfaceDescription -eq "Juniper Networks Virtual Adapter"}
    if($null -eq $pulsesecure){
    Write-Host "Please connect Pulse Secure to continue"
     Start-Sleep -Seconds 10
     $credential=get-credential
     $username=$credential.username
     $password=$credential.getnetworkcredential().password
     $arguments="-u $username -p $password -url $url -r users"
     Set-Location -Path "C:\Program Files (x86)\Common Files\Pulse Secure\JamUI"
     .\Pulse.exe -show
     Start-Sleep -Seconds 2
     Start-process "C:\Program Files (x86)\Common Files\Pulse Secure\Integration\pulselauncher.exe" -argumentlist $arguments
     Start-Sleep -Seconds 25
     $pulsesecure=Get-NetAdapter | Where-Object {$_.InterfaceDescription -eq "Juniper Networks Virtual Adapter"}
     if ($pulsesecure.status -eq "up") {
         Write-Host "Pulse Secure Connected Successfully"
         }
     else {
         Write-host "There was a problem in connecting Pulse Secure"
     }
     }
     else {
     Write-Host "Pulse Secure already connected"
     }
 
     
 
 
 # 2. Chrome cache(and cookies) be cleared (everytime it opens) - can be done by converting .ps1 to .exe and then .exe will launch chrome itself or users can do a manual setting - need to confirm
 .exe works
     taskkill /F /IM "chrome.exe"
     Start-Sleep -Seconds 5
     $Items = @('Archived History',
             'Cache\*',
             'Cookies',
             'History',
             'Login Data',
             'Top Sites',
             'Visited Links',
             'Web Data')
     $Folder = "$($env:LOCALAPPDATA)\Google\Chrome\User Data\Default"
     $Items | % { 
     if (Test-Path "$Folder\$_") {
         Remove-Item "$Folder\$_" 
         }
     }
     
 # 3. Zscalar installed and running) check .pac file - zscalar up and running can be checked and .pac files can be checked using autoconfig registry in internet settings path.
 
     Write-Host "Checking Zscalar services..."
     Start-Sleep -Seconds 3
     $zsaservices=@("zsaservice","zsatunnel","zsatraymanager")
     foreach ($service in $zsaservices) {
     if((Get-Service -Name $service).Status -eq "running"){
     write-host $service is up and running
     }
     else {
         Write-Host $service is not running
         }
     }
   #  $message="restart zscalar if the problem persists"
 
  #Need path for zscalar .pac file
     
 #4. Check genesys app - whether it's installed or not and services up and running (app is in software center)(install genesys software - pop up)
 #5. What is autocache? - http://autocache.domain.net/(zscalar not installed)
 
 #6. Site can always use cookies [*]genesyscloud.com (persistent) - need to check the feasibility
 #7. Optional - run script using task schedular
 
 .exe confirmed
 
 #15.203.228.60 - Pulse secure
 
 (Get-StoredCredential).username | Where-Object {$_ -like "*@hpe.com"}
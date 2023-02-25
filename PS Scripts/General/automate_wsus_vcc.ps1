##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepakgautam139@gmail.com                                                                                           #
#   Date :- 03-Feb-2022                                                                                                      #
#   Description :- Script is to Patch servers remotely.                                                                      #
##############################################################################################################################


<#
Summation of Job for wsus patching automation :- 
1. Function to reboot PC by checking pendingreboot flag plus a counter. Counter should be less than 1.
The function should return system reboot time.
2. Function to install wsus updates on remote PC. It should return KB installed and criteria of reboot should be checked.
Reboot criteria is that only one reboot is required.
3. Function to check differences of running services before and after the reboot. It should return the differences.
4. Optional - Function to install local PS modules on remote PC.

Things to remember :- 

a. Patch installation to continue even after the reboot only to stop if second reboot is required or there are no more updates.
b. Multiple servers should be patched at once.
c. Report generation. After the end of patching we should have a csv file with below headings: -
Hostname , Status , KbInstalled , Difference_services , reboot_time

Prerequisites :-
1. Client machines must have powershell version 5.1 or higher.
2. Client machines must have remoting enabled and configured.
#>


#$Computers = Get-Content "C:\computerlist.txt"
$ErrorActionPreference="silentlycontinue"
$user="$env:username"
$password="Password"
$passsec=ConvertFrom-SecureString -SecureString $password -AsPlainText -force


# Main

#New-NetFirewallRule -DisplayName "Allow PSWindowsUpdate" -Direction Inbound -Program "%SystemRoot%\System32\dllhost.exe" -RemoteAddress Any -Action Allow -LocalPort 'RPC' -Protocol TCP

$stopwatch=[System.Diagnostics.Stopwatch]::StartNew() ;
$results=$Computers | foreach-object -Parallel {
    Write-Host "Patching $_" -ForegroundColor "green"

    If (test-connection -ComputerName $_ -Count 1 -Quiet){

        write-host "Connection to $_ is successful" -ForegroundColor "green"
    
        # Initializing counter variable for each computer
        $counter=@{}    

        # Adding computer name to the counter variable with counter 0
        $counter.add($_,0)

        # Checking pre reboot status of running processes

        
        $previousstatus=Invoke-Command -ComputerName $_ -ScriptBlock {
        (get-service | Where-Object{$_.Status -eq "Running"} | Select-Object -Property Name).Name
        } -ErrorAction silentlycontinue

        if($? -eq $false){
            write-host "Failed to get running services on $_" -ForegroundColor "red";
            $services="failed"
        }
        <#
        # Copying local module to remote session
        write-host "Copying module to $_" -ForegroundColor "green"

        Copy-Item -Path "C:\Users\novaprime\Documents\PSWindowsUpdate" -Destination "\\$_\c$\Windows\system32\WindowsPowerShell\v1.0\Modules" -Recurse -force -ErrorAction silentlycontinue;
            
            
        if($? -eq $false){
            write-host "Failed to copy module to $_" -ForegroundColor "red";
            $status="Copy failed"
            $issue=$($Error[0].Exception.Message)
            $KBinstalled="None"
            $difference="None"
            break;
        }
        #>   
        # Starting do loop

        do {
            # Getting the counter value
            write-host "Starting do loop for $_" -ForegroundColor "green"
            
            Write-Host ('counter value of {0} is {1}' -f $_,$counter[$_]) -ForegroundColor Green
            
            # Getting the current status of running services
            if($services -ne "failed"){
                $poststatus= Invoke-Command -ComputerName $_ -ScriptBlock {
                (get-service | Where-Object{$_.Status -eq "Running"} | Select-Object -Property Name).Name
                }
            }
            

            Invoke-Command -ComputerName $_ -ScriptBlock {
                Import-Module 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate\2.2.0.2\PSWindowsUpdate.psd1';
            } -ErrorAction SilentlyContinue

            if($? -eq $false){
                write-host "Failed to import module to $_" -ForegroundColor "red";
                $status="Import failed"
                $issue=$($Error[0].Exception.Message)
                $KBinstalled="None"
                $difference="None"
                break;
            }

            # checking if there are any windows update to isntall
            #$updates=get-windowsupdate -ComputerName $_ -AcceptAll -IgnoreReboot -ErrorAction SilentlyContinue
            $s=New-PSSession -ComputerName $_ -Credential $user -Password $passsec -ErrorAction SilentlyContinue
            
            $updates=Invoke-Command -Session $s -ScriptBlock {
                Get-WindowsUpdate -AcceptAll -IgnoreReboot
            } -ErrorAction SilentlyContinue

            if($? -eq $false){
                write-host "Failed to get updates on $_" -ForegroundColor "red";
                $status="Get updates failed"
                $issue=$($Error[0].Exception.Message)
                $KBinstalled="None"
                $difference="None"
                break;
            }                
               
            if($updates.Count -eq 0){
                    
                write-host "No more updates to install on $_" -ForegroundColor "green"
                    
                $status="No more updates to install"
                $issue="None"
                #Add command to check for installed updates
                $KBinstalled=Invoke-Command -Session $s -ScriptBlock {
                (Get-HotFix | Where-Object {$_.installedon -gt (get-date).AddDays(-1)} | `
                Select-Object hotfixID -ExpandProperty hotfixID) -join ","} -ErrorAction SilentlyContinue
                    
                if($services -ne "failed"){
                    if([string]::IsNullOrEmpty(($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ",")){
                        $difference = "No difference"
                    }
                    else{
                        $difference = ($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ","
                    }
                }
                break;
                }

                # installing windows update on remote computer
                
                Write-Host "Installing updates on $_" -ForegroundColor "green"

                Invoke-Command -Session $s -scriptblock{ Install-WindowsUpdate -ComputerName $_ -kbarticleID KB4339284 -IgnoreReboot -Confirm:$false -Verbose | `
                Out-File -FilePath C:\temp\report.log -Append -Force -Verbose;
                }
                
                if($? -eq $false){
                    write-host "Installation failed on $_" -ForegroundColor "red";
                    $status="Module failed"
                    $issue=$($Error[0].Exception.Message)
                    $KBinstalled=Invoke-Command -ComputerName $_ -ScriptBlock {
                    (Get-HotFix | Where-Object {$_.installedon -gt (get-date).AddDays(-1)} | `
                    Select-Object hotfixID -ExpandProperty hotfixID) -join ","}
                    $difference="None"
                    break;
                }

                # checking reboot status of the server

                if(Get-WURebootStatus -ComputerName $_  -SilentlyContinue){      
                    if($counter[$_] -eq "0"){
        
                        Write-Host "Reboot required on $_" -ForegroundColor "red";
                
                        Restart-Computer -Wait -For PowerShell -ComputerName $_ -Confirm:$false -Timeout 600 -delay 5 -Force;
                        
                        # check if the server is up after reboot and add command
                        
                        if($? -eq $false){
                            write-host "Restart failed on $_" -ForegroundColor "red";
                            $status="Either restar failed or server is down"
                            $issue=$($Error[0].Exception.Message)
                            
                            $KBinstalled=Invoke-Command -Session $s -ScriptBlock {
                            (Get-HotFix | Where-Object {$_.installedon -gt (get-date).AddDays(-1)} | `
                            Select-Object hotfixID -ExpandProperty hotfixID) -join ","} -ErrorAction SilentlyContinue

                            if($services -ne "failed"){
                                if([string]::IsNullOrEmpty(($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ",")){
                                $difference = "No difference"
                                }
                                else{
                                $difference = ($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ","
                                }
                            }
                            break;
                        }
                        
                        $counter[$_]++;
                        Write-Host counter value of $_ is $counter[$_] -ForegroundColor Green
                    }
                    else {
                        write-host "another reboot required - so skipping on $_" -ForegroundColor "green";
                        $status="Patched"
                        $issue="None"
                
                        $KBinstalled=Invoke-Command -Session $s -ScriptBlock {
                        (Get-HotFix | Where-Object {$_.installedon -gt (get-date).AddDays(-1)} | `
                        Select-Object hotfixID -ExpandProperty hotfixID) -join ","} -ErrorAction SilentlyContinue
                        
                        if($services -ne "failed"){
                            if([string]::IsNullOrEmpty(($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ",")){
                                $difference = "No difference"
                            }
                            else{
                            $difference = ($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ","
                            }
                        }
                        Break;
                    }
                }
                else{
                    Write-Host "Reboot not required on $_, hence continued" -ForegroundColor "green";
                }

        } while ($counter[$_] -lt "2")
    }
    else
    {   
        $status = "Unreachable"
        $issue="Destination host is not reachable"
        $KBinstalled="None"
        $difference="None"
    }

    try {
        $uptime=[System.Management.ManagementDateTimeconverter]::ToDateTime($(Get-WmiObject -ComputerName $_ -Class Win32_OperatingSystem  | `
                        Select-Object -ExpandProperty LastBootUpTime))
    }
    catch {
        $uptime="failure"
    }

    if($services -eq "failed"){
        $difference="services failed"
    }
    
    [pscustomobject]@{
        'Computer'=$_
        'Status'=$status
        'Error'=$issue
        'KBinstalled'=$KBinstalled
        'difference_services'=$difference
        'Reboot'=$uptime
    }
} -ThrottleLimit 10 -AsJob | Receive-Job -Wait -AutoRemoveJob
$stopwatch.stop();
$stopwatch.elapsed.seconds ;

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force
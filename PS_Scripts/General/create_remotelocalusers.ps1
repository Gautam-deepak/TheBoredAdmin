###########################################################################################################################################
#   Author :- Deepak Gautam                                                                                                               #
#   Email :- deepakgautam139@gmail.com                                                                                                        #
#   Date :- 18-Jan-2022                                                                                                                   #
#   Description :- Script is to automate the local admin creation on member servers                                                       #
###########################################################################################################################################

<#
Note - The script utilizes foreach-object Parallel feature to run the remote jobs concurrently. The throttle limit on foreach-object must be 
choosen carefully. Before running the script use start-transcript to the capture output and stop-transcript post the script is run.

e.g. 

start-transcript -path c:\result.txt -force
.\script.ps1
stop-transcript

Once the output is captured in text file , verify the output and add headers. Once done, save the output as csv format to apply filters.

HAPPY SCRIPTING !!!!!!

#>

#Define variables
$computers = Get-ADComputer -Filter 'operatingsystem -like "*server*" -and enabled -eq "true" -and primarygroupid -ne "516"' | `
            Select-Object -Property Name -ExpandProperty name
$ErrorActionPreference='stop'
$username = 'PAMBGADMIN'
$password = ''
$fullname = 'Break Glass Accounts'
$local_security_group = 'Administrators'
$description = "PAM Break Glass Accounts created"

#main

 $computers | ForEach-Object -Parallel {
        
            If (test-connection -ComputerName $_ -Count 1 -Quiet){
                $users = $null
                $comp = [ADSI]('WinNT://{0}' -f $_)
                
                Try {
                    $users = $comp.psbase.children | Select-Object -expand name
                    if ($users -like $using:username) {
                        
                        $Userstatus = 'User Already exists'

                        $groupmember=Invoke-Command -ComputerName $_ -ScriptBlock {
                                net localgroup 'administrators'
                            } -ErrorAction SilentlyContinue
                      if($? -eq $true){
                        if($groupmember -contains $using:username){
                             
                          $Member='User Already a member'
                          $problem='No Error'
                        }
                        else{
                            Invoke-Command -ComputerName $_ -ScriptBlock {
                                net localgroup 'administrators' 'PAMBGADMIN' /add | Out-Null
                        } -ErrorAction SilentlyContinue
                          
                          $Member='Added'
                          $problem='No Error'
                        }
                      }
                      else{
                        $Member='Failed'
                        $problem=$($Error[0].exception.message)
                      }

                      $status=$Userstatus
                      $Membership=$member
                      $issue=$problem
                     
                    } 
                    
                        else {
                        #Create the account
                        $user = $comp.Create('User',$using:username)
                        $user.SetPassword($using:password)
                        $user.Put('Description',$using:description)
                        $user.Put('Fullname',$using:Fullname)
                        $user.SetInfo()
                     
                        #Set password to never expire
                        #And set user cannot change password
                        $ADS_UF_DONT_EXPIRE_PASSWD = 0x10000
                        $ADS_UF_PASSWD_CANT_CHANGE = 0x40
                        $user.userflags = $ADS_UF_DONT_EXPIRE_PASSWD + $ADS_UF_PASSWD_CANT_CHANGE
                        $user.SetInfo()
                        $userstatus='User Created'
                       
                              Invoke-Command -ComputerName $_ -ScriptBlock {
                              net localgroup 'administrators' 'PAMBGADMIN' /add | Out-Null
                            } -ErrorAction SilentlyContinue
                          if($? -eq $true){
                            
                            $member='Added'
                            $problem='No Error'
                            
                        }
                        else{
                    
                          $member='Failed'
                          $problem=$($Error[0].exception.message)
                        }
                      $status = $userstatus
                      $Membership = $Member
                      $issue=$problem
                    } 
                }
                Catch {  
                    
                    $status = 'Failed'
                    $Membership = 'NA'
                    $issue=$($Error[0].exception.message)
        
                }
        
                Finally{
                    $Error.Clear()
                }
                
                
            }   
            else{   
            
            $status = 'Unreachable'
            $issue='Destination host is not reachable'
            $Membership = 'NA'
        }

       Write-host ('{0},{1},{2},{3}' -f $_,$status,$issue,$membership)


    }  -ThrottleLimit 250 -AsJob | Receive-Job -Wait -AutoRemoveJob

    
    
    
    

      
##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepak.gautam@hpe.com                                                                                           #
#   Date :- 20-May-2022                                                                                                      #
#   Description :- Script is to trigger Patching Task on remote windows servers                                              #
##############################################################################################################################

<#
    Bugs:-

    1. Script stopped altogether when copy command failed on one of the server - fixed
    2. Script execution waits perpetually if an error happens on remote machine - fixed 
    3. WinRm Error on 23/06/2022 in Lab - Reason Unknown - Pending
    WinRM Error on multiple machines in production - script execution stops altogether when error happens 

    ErrorRecord                 : [server2] Connecting to remote server server2 failed with the following error message : WinRM cannot complete the operation. Verify that the specified computer name is valid, that
                                  the computer is accessible over the network, and that a firewall exception for the WinRM service is enabled and allows access from this computer. By default, the WinRM firewall
                                  exception for public profiles limits access to remote computers within the same local subnet. For more information, see the about_Remote_Troubleshooting Help topic.
    WasThrownFromThrowStatement : False
    TargetSite                  : System.Collections.ObjectModel.Collection`1[System.Management.Automation.PSObject] Invoke(System.Collections.IEnumerable)
    Message                     : The running command stopped because the preference variable "ErrorActionPreference" or common parameter is set to Stop: [server2] Connecting to remote server server2 failed with
                                  the following error message : WinRM cannot complete the operation. Verify that the specified computer name is valid, that the computer is accessible over the network, and that a
                                  firewall exception for the WinRM service is enabled and allows access from this computer. By default, the WinRM firewall exception for public profiles limits access to remote
                                  computers within the same local subnet. For more information, see the about_Remote_Troubleshooting Help topic.
    Data                        : {System.Management.Automation.Interpreter.InterpretedFrameInfo}
    InnerException              :
    HelpLink                    :
    Source                      : System.Management.Automation
    HResult                     : -2146233087
    StackTrace                  : at System.Management.Automation.Runspaces.PipelineBase.Invoke(IEnumerable input)
                                  at Microsoft.PowerShell.Executor.ExecuteCommandHelper(Pipeline tempPipeline, Exception& exceptionThrown, ExecutionOptions options)
    
    4. Log Name:      Microsoft-Windows-TaskScheduler/Operational
    Source:        Microsoft-Windows-TaskSchedule
    Date:          6/25/2022 7:45:34 PM
    Event ID:      153
    Task Category: Missed task start rejected
    Level:         Warning
    Keywords:    
    User:          SYSTEM
    Computer:      computername
    Description:
    Task Scheduler did not launch task "\Patching" as it missed its schedule. Consider using the configuration option to start the task when available, if schedule is missed.
    Event Xml:
    <Event xmlns="http://schemas.microsoft.com/win/2004/08/events/event">
    <System>
    <Provider Name="Microsoft-Windows-TaskScheduler" Guid="{DE7B24EA-73C8-4A09-985D-5BDADCFA9017}" />
    <EventID>153</EventID>
    <Version>0</Version>
    <Level>3</Level>
    <Task>153</Task>
    <Opcode>0</Opcode>
    <Keywords>0x8000000000000000</Keywords>
    <TimeCreated SystemTime="2022-06-25T14:15:34.627609000Z" />
    <EventRecordID>318175</EventRecordID>
    <Correlation />
    <Execution ProcessID="1228" ThreadID="1340" />
    <Channel>Microsoft-Windows-TaskScheduler/Operational</Channel>
    <Computer>UMUMDVIMIE.upl.com</Computer>
    <Security UserID="S-1-5-18" />
    </System>
    <EventData Name="MissedTaskRejected">
    <Data Name="TaskName">\Patching</Data>
    </EventData>      
    </Event>

    Remote servers are rejecting the schedule task trigger with error : the operator or administrator has refused the request. (0x800710E0)


#>

<#
    Improvement - 

    1. re-run script for servers where history file have "failed/in-progress" status - pending
    2. How to identify which history file is missing - fixed 
    3. How to identify a reboot loop of remote machine - fixed 

#>

# Trigger the scheduled task remotely and get the result of the windows update installation 


<#PSScriptInfo

    .VERSION 1.0.0

    .GUID 811639a6-27c1-43ad-8a48-4730324f6fc9

    .AUTHOR Deepak.Gautam@hpe.com

    .COMPANYNAME Hewlett Packard Enterprise

    .COPYRIGHT Hewlett Packard Enterprise. All rights reserved.

    .TAGS Tag1 Tag2 Tag3

    .LICENSEURI https://contoso.com/License

    .PROJECTURI https://contoso.com/

    .ICONURI https://contoso.com/Icon

    .EXTERNALMODULEDEPENDENCIES ff,bb 

    .REQUIREDSCRIPTS Start-WFContosoServer,Stop-ContosoServerScript

    .EXTERNALSCRIPTDEPENDENCIES Stop-ContosoServerScript

    .RELEASENOTES
    Contoso script now supports the following features:
    Feature 1
    Feature 2
    Feature 3
    Feature 4
    Feature 5

    .PRIVATEDATA

#>

#Requires -Module @{ModuleName = 'PSBanner'; ModuleVersion = '1.0.0'}

<# 

    .DESCRIPTION 
    Script is to trigger Patching Task on remote windows servers

#> 

param(
  [Parameter(Mandatory=$true,HelpMessage='Path for computer text file')][string]$computerfilepath,
  [ValidateSet('Patching','UndoPatching')]
  [string]$taskname='Patching',
  [string]$sendreportto=$null
)

# Variables

$stopwatch =  [diagnostics.stopwatch]::StartNew()

$Author='deepak.gautam@hpe.com'

$scriptpath = "$env:HOMEDRIVE\Temp"

$CPPostRebootTask='CPPostReboottask'

$computers=Get-Content -Path $computerfilepath

$passwordfilepath="$env:HOMEDRIVE\temp\password"

$EmailFrom=''

# Using the encrypted password again in the script

$encrypted=Get-Content -Path $passwordfilepath\password.txt | ConvertTo-SecureString -Key (Get-Content -Path $passwordfilepath\aeskey.key)

# Using the saved password and username in the credential

$credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($EmailFrom,$encrypted)

$ErrorActionPreference='stop'

$WarningPreference='silentlycontinue'

$VerbosePreference = 'Continue'

$patched=('{0}\Patched_Servers.txt' -f ($scriptpath))

$Failed=('{0}\Failed_Servers.txt' -f ($scriptpath))

$Unreachable=('{0}\Unreachable_Servers.txt' -f ($scriptpath))

$Failed_history=('{0}\Failed_History.txt' -f ($scriptpath))

$Reboot_loop=('{0}\Reboot_loop.txt' -f ($scriptpath))

$domain='UPL.COM'

$destfile= ("$env:HOMEDRIVE\temp\results\" + 'Patching_Status.txt')

# Parameters to send email reports
$params=@{
  To=$sendreportto
  CC=$Author
  From=$emailfrom
  Credential=$credential
  Body=('Please find the attached Patching Status of {0} dated {1}.' -f $domain,(Get-Date).GetDateTimeFormats()[-3])
  Subject='Patching Status'
  SmtpServer='smtp.office365.com'
  Port=587
  UseSsl=$true
  Attachments="$env:HOMEDRIVE\temp\combinedfile.csv","$env:HOMEDRIVE\temp\results\Patching_Status.txt"
}


# Creating files and folders necessary for execution of the script

If(!(Test-path -Path $env:HOMEDRIVE\temp\results)){$null = New-Item -Name Temp -Path $env:HOMEDRIVE\results -ItemType Directory}

# patched servers are added to this file
$null = New-Item -ItemType File -Path $scriptpath -Name Patched_servers.txt -Force

# Failed servers are added to this file
$null = New-Item -ItemType File -Path $scriptpath -Name Failed_servers.txt -Force

# Unreachable servers are added to this file
$null = New-Item -ItemType File -Path $scriptpath -Name Unreachable_servers.txt -Force

# Servers where history file couldn't be copied are added to this file
$null = New-Item -ItemType File -Path $scriptpath -Name Failed_History.txt -Force

# Servers which are in Reboot loop for more than 90 minutes are added to this file
$null = New-Item -ItemType File -Path $scriptpath -Name Reboot_loop.txt -Force

# Starting transcript
Start-Transcript -path $scriptpath\AutoPatching_Transcript.txt -Force


# Writing Autopatch Banner
Write-Banner A u t o P a t c h

# Display Author Information

$wshell=(New-Object -ComObject Wscript.Shell -ErrorAction SilentlyContinue)
$null = $wshell.Popup("
    Patching Automation is created by Deepak Gautam from Wintel. `

    For any query, please contact at deepak.gautam@hpe.com. `

    Happy Patching !!!!!!!",0,'Author Information',64+0)

$null = $wshell.Popup("   MIT License

    Copyright (c) [2022] [Deepak Gautam]

    Permission is hereby granted, free of charge, to any 
    person obtaining a copy of this software and associated 
    documentation files (the AutoPatch), to deal in the 
    Software without restriction, including without limitation 
    the rights to use, copy, modify, merge, publish, distribute, 
    sublicense, and/or sell copies of the Software, and to permit 
    persons to whom the Software is furnished to do so, subject 
    to the following conditions:

    The above copyright notice and this permission notice shall 
    be included in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY 
    OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
    LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
    IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS 
    BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
    WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, 
    ARISING FROM,OUT OF OR IN CONNECTION WITH THE SOFTWARE 
    OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.",0,'
    License Information',64+0)

# Functions

# Creating final report and sending reports 
function send-finalreport {
  <#
      .SYNOPSIS
      Describe purpose of "send-finalreport" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      send-finalreport
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online send-finalreport

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


  [CmdletBinding()]
  param (
      
  )
  
  begin {
    Write-Verbose -Message 'Creating final report...'
  }
  
  process {
    try{
      Remove-Item -Path $scriptpath\results\Patching_Status.txt -Force
      get-ChildItem -Path $scriptpath -File -Filter *.txt | ForEach-Object {'________________________' | `
      out-file  -FilePath $destfile -Append; $_.Name  | Out-File  -FilePath $destfile -Append; Get-Content -Path $_.FullName | `
      Out-File  -FilePath $destfile -Append}

      [Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12

      If([string]::IsNullOrEmpty($sendreportto)){
        Write-Verbose -Message 'No email sent' -Verbose
      }
      else{
        Send-MailMessage @params 
        Write-Verbose -Message 'Final report created and sent' -Verbose
      }
    }
    catch{
      Write-Verbose -message ('Send Report Error:{0} :{1}' -f $error[0].InvocationInfo.MyCommand, $error[0].Exception.Message) -Verbose
    }
  }
  
  end {
    $error.Clear()
  }
}

# Creating Main History file by combining all the history files from all the servers
function set-history {
  <#
      .SYNOPSIS
      Describe purpose of "set-history" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .EXAMPLE
      set-history
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online set-history

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


  [CmdletBinding()]
  param (
    
  )
  
  begin {
    Write-Verbose -Message 'Creating combined history file'
  }
  
  process {
    try {
      Get-ChildItem -Filter *.csv -Path $scriptpath | Select-Object -ExpandProperty FullName | `
      Import-Csv | Export-Csv -Path $scriptpath\CombinedFile.csv -NoTypeInformation -Force
      Write-Verbose -Message (('Combined file created at {0}\CombinedFile.csv' -f ($scriptpath))) -Verbose   
    }
    catch {
      Write-Verbose -Message (('Combined file not created at {0}\CombinedFile.csv' -f ($scriptpath))) -Verbose
      Write-Verbose -message ('Send Report Error:{0} :{1}' -f $error[0].InvocationInfo.MyCommand, $error[0].Exception.Message) -Verbose
    }
  }
  
  end {
    $error.Clear()
  }
}

Function invoke-parallelPatching {
    <#
  .SYNOPSIS
  <Overview of script>
  
  .DESCRIPTION
  <Brief description of script>
  
  .PARAMETER <Parameter_Name>
    <Brief description of parameter input required. Repeat this attribute if required>
  
    .INPUTS
  <Inputs if any, otherwise state None>

  .OUTPUTS
  <Outputs if any, otherwise state None - example: Log file stored in C:\Windows\Temp\<name>.log>

  .NOTES
  Version:        1.0
  Author:         <Name>
  Creation Date:  <Date>
  Purpose/Change: Initial script development
  
  .EXAMPLE
    <Example goes here. Repeat this attribute for more than one example>
  #>

  param(
    [parameter(Mandatory=$true,HelpMessage='Add help message for user')][string[]]$computers
  )
  
  $computers | foreach-object -Parallel {

    # Inline Function to check status of the execution at run time 
    function Get-PatchStatus{
      <#
          .SYNOPSIS
          Function to check status of the execution at run time 

          .DESCRIPTION
          Function provides more information about no. of servers in installing , failed, unreachable states

          .EXAMPLE
          Get-PatchStatus
          Provide no. of servers in different stages

          Total servers : , Failed servers : , Installing servers : , Unreachable servers :

          .NOTES
          Function is placed in foreach-object Parallel to be available in inline script everytime.

          .INPUTS
          No Input Required in the function

          .OUTPUTS
          Total servers : , Failed servers : , Installing servers : , Unreachable servers :
      #>

      # Getting status of all files related to execution of the script
      $runtime_patch=Get-Content -Path $using:patched
      $runtime_fail=Get-Content -Path $using:failed
      $runtime_unreach=Get-Content -Path $using:unreachable

      # Calculating no. of servers in different stages
      Write-Verbose -Message ('Total Servers:{0}, Patched Servers:{1}, Failed Servers:{2}, Unreachable servers:{3}, Installing:{4}' -f `
        $using:computers.count,$runtime_patch.count,$runtime_fail.count,$runtime_unreach.count,`
      ($using:computers.count-$runtime_patch.count-$runtime_fail.count-$runtime_unreach.count)) -Verbose
    }

    # Checking if remote machine is reachable

    If (test-connection -ComputerName $_ -Count 1 -Quiet){
      Try{
        # Invoking Patching task on remote servers

        If((Invoke-Command -ComputerName $_ -ArgumentList $using:taskname -ScriptBlock{
          param([Parameter(Mandatory=$true)][string]$task)Get-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue}).state -ne 'Running'){  
        
          # Checking if Continue Patching Reboot Task exists or not , if not then starting Patching Task 
          If(!(Invoke-Command -ComputerName $_ -ArgumentList $using:cppostreboottask -ScriptBlock{
            param([Parameter(Mandatory=$true)][string]$CPtask)Get-ScheduledTask -TaskName $CPtask -ErrorAction SilentlyContinue})){
        
            # Starting Patching Task only if it's not running and CPPostRebootTask doesn't exist
            Invoke-Command -ComputerName $_ -ArgumentList $using:taskname -ScriptBlock{ 
              param([Parameter(Mandatory=$true)][string]$task)Start-ScheduledTask -TaskName $task -ErrorAction 'stop'}
            Write-Verbose -Message ('Scheduled Task Triggered on {0}' -f $_) -Verbose
            start-sleep -Seconds 5
          } 
        }
            
        do {
          # Installation starts from here 

          Write-Verbose -Message ('Installing Windows Updates on {0}' -f $_) -Verbose
          start-sleep -Seconds 20

          # Checking if the remote script is running or not
          If(Invoke-Command -ComputerName $_ -ScriptBlock {test-path -Path $env:HOMEDRIVE\Temp\is_stopped.txt}){
            
            Write-Verbose -Message ('Local Script execution has stopped on {0}, please check...' -f $_) -Verbose
            
            # If remote script is stopped, adding the server in the failed servers list
            Add-Content -Path $using:failed -Value $_
            # Breaking out of nested loops
            Break outer 
          }
          # setting a reboot timer for the remote server  
          $reboot_stopwatch=[diagnostics.stopwatch]::StartNew()
        
          # Checking if the remote machine is being rebooted based on availability of Lanmanserver service

          while (!(
              'Running' -eq (Invoke-Command -ComputerName $_ -ScriptBlock {Get-Service -Name lanmanserver} -ErrorAction silentlycontinue).status
          )) {
            Write-Verbose -Message ('{0} is being rebooted since {1} minutes, please wait for the installation to continue' `
            -f $_,$reboot_stopwatch.Elapsed.totalminutes) -Verbose
            Start-Sleep -Seconds 10

            # Checking if it's been 90 minutes since reboot
            if($reboot_stopwatch.Elapsed.TotalMinutes -ge 90){
              Write-Verbose -Message ('{0} is not rebooting after 90 minutes, hence exiting the script' -f $_) -Verbose
              # If system is rebooting since more than 90 minutes, breaking out of the loop and add the server in reboot loop list
              Add-Content -Path $using:Reboot_loop -Value $_ 
              break outer
            }
          }    
        } while (
          !((test-connection -ComputerName $_ -Count 1 -Quiet) -and
            ((Invoke-Command -ComputerName $_ -ArgumentList $using:taskname -ScriptBlock {
              param([Parameter(Mandatory=$true)][string]$task)(Get-ScheduledTask -TaskName $task).State} -ErrorAction SilentlyContinue).value -eq 'Ready') -and 
            ($null -eq (Invoke-Command -ComputerName $_ -ArgumentList $using:cppostreboottask -ScriptBlock {
              param([Parameter(Mandatory=$true)][string]$CPtask)(Get-ScheduledTask -TaskName $CPtask -ErrorAction silentlycontinue)} -ErrorAction silentlycontinue)) -and 
            (Invoke-Command -ComputerName $_ -ScriptBlock {Test-Path -Path "C:\temp\$($env:COMPUTERNAME)-history.csv"} -ErrorAction silentlycontinue)
        ))

        # Installation should complete at this point
        Write-Verbose -Message ('Installation completed on {0}' -f $_) -Verbose
        # Adding patched servers in the patched servers list
        Add-Content -Path $using:patched -Value $_ 
        # Checking Current status of the execution
        Get-PatchStatus

        # Copying the history file to the local machine
        Copy-Item -Path \\$_\c$\Temp\$($_)-history.csv -Destination "\\$($env:COMPUTERNAME)\c$\temp" -Force -ErrorAction silentlycontinue 
            
        if($?){
          Write-Verbose -Message ('History file copied from {0}' -f $_) -Verbose
          Write-Verbose -Message ('Please check the history file of {0} in c:\temp' -f $_) -Verbose
        }
        else{
          # If history file is not copied, adding the server in the failed history list
          Write-Verbose -Message ('History file copy failure from {0}' -f $_) -Verbose
          Add-Content -Path $using:Failed_history -Value $_ 
        }            
      }
      catch{
        # If any exception is thrown, adding the server in the Failed servers list
        Write-Verbose -Message ('Update Installation failed on {0} at line {1} with Error : {2}' -f $_,$error[0].InvocationInfo.MyCommand,$error[0].Exception.Message) -Verbose
        Add-Content -Path $using:Failed -Value $_ 
        # Checking current status of the execution
        Get-PatchStatus            
      }
    }
    else {
      # If remote machine is not reachable, adding the server in the Unreachable servers list
      Write-Verbose -Message ('{0} is not reachable' -f $_) -Verbose 
      Add-Content -Path $using:Unreachable -Value $_ 
      # Checking current status of the execution
      Get-PatchStatus
    }
  } -ThrottleLimit 100 -AsJob | Receive-Job -Wait -AutoRemoveJob
}


# Main
invoke-parallelPatching -computers $computers
set-history
send-finalreport

# Exit Formalities
Write-verbose -message ('Total Time taken to patch {0} servers : {1} minutes' -f $computers.count,$stopwatch.Elapsed.Minutes) -Verbose
Write-verbose -message ('Exiting script, Goodbye.....') -Verbose
Stop-Transcript
  
 
 
 
 

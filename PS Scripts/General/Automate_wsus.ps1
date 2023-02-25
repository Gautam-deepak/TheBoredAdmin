##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepakgautam139@gmail.com                                                                                           #
#   Date :- 06-Dec-2021                                                                                                      #
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

a. Patch installation to continue even after the reboot only to stop if second reboot is required.
b. Multiple servers should be patched at once.
c. Report generation. After the end of patching we should have a csv file with below headings: -

Hostname , IP , KbInstalled , Difference_services , reboot_time

#>



$Computers = Get-Content "C:\computerlist.txt"
$ErrorActionPreference="Stop"
$Global:pendingrebootstat=""
[int]$global:pendingrebootcounter="0"
$user="$env:username"
$password=ConvertTo-SecureString -String "Password" -AsPlainText -Force
$credential=New-Object System.Management.Automation.PSCredential($user,$password)
$date=Get-Date

# Functions

function get-Module ($m) {

    # If module is imported say that and do nothing
    if (Get-Module | Where-Object {$_.Name -eq $m}) {
        write-host "Module $m is already imported."
    }
    else {

        # If module is not imported, but available on disk then import
        if (Get-Module -ListAvailable | Where-Object {$_.Name -eq $m}) {
            Import-Module $m -Verbose
        }
        else {

            # If module is not imported, not available on disk, but is in online gallery then install and import
            if (Find-Module -Name $m | Where-Object {$_.Name -eq $m}) {
                Install-Module -Name $m -Force -Verbose -Scope CurrentUser
                Import-Module $m -Verbose
            }
            else {

                # If the module is not imported, not available and not in the online gallery then abort
                write-host "Module $m not imported, not available and not in an online gallery, exiting."
                EXIT 1
            }
        }
    }
}

Function Invoke-WUInstall
{
    <#
    .SYNOPSIS
        Invoke Get-WUInstall remotely.
 
    .DESCRIPTION
        Use Invoke-WUInstall to invoke Windows Update install remotly. It Based on TaskScheduler because
        CreateUpdateDownloader() and CreateUpdateInstaller() methods can't be called from a remote computer - E_ACCESSDENIED.
         
        Note:
        Because we do not have the ability to interact, is recommended use -AcceptAll with WUInstall filters in script block.
     
    .PARAMETER ComputerName
        Specify computer name.
 
    .PARAMETER TaskName
        Specify task name. Default is PSWindowsUpdate.
         
    .PARAMETER Script
        Specify PowerShell script block that you what to run. Default is {ipmo PSWindowsUpdate; Get-WUInstall -AcceptAll | Out-File C:\PSWindowsUpdate.log}
         
    .EXAMPLE
        PS C:\> $Script = {ipmo PSWindowsUpdate; Get-WUInstall -AcceptAll -AutoReboot | Out-File C:\PSWindowsUpdate.log}
        PS C:\> Invoke-WUInstall -ComputerName pc1.contoso.com -Script $Script
        ...
        PS C:\> Get-Content \\pc1.contoso.com\c$\PSWindowsUpdate.log
         
    .LINK
        Get-WUInstall
    #>
    [CmdletBinding(
        SupportsShouldProcess=$True,
        ConfirmImpact="High"
    )]
    param
    (
        [Parameter(ValueFromPipeline=$True,
                    ValueFromPipelineByPropertyName=$True)]
        [String[]]$ComputerName,
        [String]$TaskName = "PSWindowsUpdate",
        [ScriptBlock]$Script = {Import-Module PSWindowsUpdate; Get-WUInstall -AcceptAll | Out-File C:\PSWindowsUpdate.log},
        [Switch]$OnlineUpdate
    )

    Begin
    {
        $User = [Security.Principal.WindowsIdentity]::GetCurrent()
        $Role = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)

        if(!$Role)
        {
            Write-Warning "To perform some operations you must run an elevated Windows PowerShell console."    
        } #End If !$Role
        
        $PSWUModule = Get-Module -Name PSWindowsUpdate -ListAvailable
        
        Write-Verbose "Create schedule service object"
        $Scheduler = New-Object -ComObject Schedule.Service
            
        $Task = $Scheduler.NewTask(0)

        $RegistrationInfo = $Task.RegistrationInfo
        $RegistrationInfo.Description = $TaskName
        $RegistrationInfo.Author = $User.Name

        $Settings = $Task.Settings
        $Settings.Enabled = $True
        $Settings.StartWhenAvailable = $True
        $Settings.Hidden = $False

        $Action = $Task.Actions.Create(0)
        $Action.Path = "powershell"
        $Action.Arguments = "-Command $Script"
        
        $Task.Principal.RunLevel = 1    
    }
    
    Process
    {
        ForEach($Computer in $ComputerName)
        {
            If ($pscmdlet.ShouldProcess($Computer,"Invoke WUInstall")) 
            {
                if(Test-Connection -ComputerName $Computer -Quiet)
                {
                    Write-Verbose "Check PSWindowsUpdate module on $Computer"
                    Try
                    {
                        $ModuleTest = Invoke-Command -ComputerName $Computer -ScriptBlock {Get-Module -ListAvailable -Name PSWindowsUpdate} -ErrorAction Stop
                    } #End Try
                    Catch
                    {
                        Write-Warning "Can't access to machine $Computer. Try use: winrm qc"
                        Continue
                    } #End Catch
                    $ModulStatus = $false
                    
                    if($ModuleTest -eq $null -or $ModuleTest.Version -lt $PSWUModule.Version)
                    {
                        if($OnlineUpdate)
                        {
                            Update-WUModule -ComputerName $Computer
                        } #End If $OnlineUpdate
                        else
                        {
                            Update-WUModule -ComputerName $Computer    -LocalPSWUSource (Get-Module -ListAvailable -Name PSWindowsUpdate).ModuleBase
                        } #End Else $OnlineUpdate
                    } #End If $ModuleTest -eq $null -or $ModuleTest.Version -lt $PSWUModule.Version
                    
                    #Sometimes can't connect at first time
                    $Info = "Connect to scheduler and register task on $Computer"
                    for ($i=1; $i -le 3; $i++)
                    {
                        $Info += "."
                        Write-Verbose $Info
                        Try
                        {
                            $Scheduler.Connect($Computer)
                            Break
                        } #End Try
                        Catch
                        {
                            if($i -ge 3)
                            {
                                Write-Error "Can't connect to Schedule service on $Computer" -ErrorAction Stop
                            } #End If $i -ge 3
                            else
                            {
                                Start-Sleep -Seconds 1
                            } #End Else $i -ge 3
                        } #End Catch
                    } #End For $i=1; $i -le 3; $i++
                    
                    $RootFolder = $Scheduler.GetFolder("\")
                    $SendFlag = 1
                    if($Scheduler.GetRunningTasks(0) | Where-Object {$_.Name -eq $TaskName})
                    {
                        $CurrentTask = $RootFolder.GetTask($TaskName)
                        $Title = "Task $TaskName is curretly running: $($CurrentTask.Definition.Actions | Select-Object -exp Path) $($CurrentTask.Definition.Actions | Select-Object -exp Arguments)"
                        $Message = "What do you want to do?"

                        $ChoiceContiniue = New-Object System.Management.Automation.Host.ChoiceDescription "&Continue Current Task"
                        $ChoiceStart = New-Object System.Management.Automation.Host.ChoiceDescription "Stop and Start &New Task"
                        $ChoiceStop = New-Object System.Management.Automation.Host.ChoiceDescription "&Stop Task"
                        $Options = [System.Management.Automation.Host.ChoiceDescription[]]($ChoiceContiniue, $ChoiceStart, $ChoiceStop)
                        $SendFlag = $host.ui.PromptForChoice($Title, $Message, $Options, 0)
                    
                        if($SendFlag -ge 1)
                        {
                            ($RootFolder.GetTask($TaskName)).Stop(0)
                        } #End If $SendFlag -eq 1
                        
                    } #End If !($Scheduler.GetRunningTasks(0) | Where-Object {$_.Name -eq $TaskName})
                        
                    if($SendFlag -eq 1)
                    {
                        $RootFolder.RegisterTaskDefinition($TaskName, $Task, 6, "SYSTEM", $Null, 1) | Out-Null
                        $RootFolder.GetTask($TaskName).Run(0) | Out-Null
                    } #End If $SendFlag -eq 1
                    
                    #$RootFolder.DeleteTask($TaskName,0)
                } #End If Test-Connection -ComputerName $Computer -Quiet
                else
                {
                    Write-Warning "Machine $Computer is not responding."
                } #End Else Test-Connection -ComputerName $Computer -Quiet
            } #End If $pscmdlet.ShouldProcess($Computer,"Invoke WUInstall")
        } #End ForEach $Computer in $ComputerName
        Write-Verbose "Invoke-WUInstall complete."
    }
    
    End {}

}

Function Write-Log # Function to write log
{
  <#
      .SYNOPSIS
      Describe purpose of "Write-Log" in 1-2 sentences.

      .DESCRIPTION
      Add a more complete description of what the function does.

      .PARAMETER LogOutput
      Describe parameter -LogOutput.

      .EXAMPLE
      Write-Log -LogOutput Value
      Describe what this call does

      .NOTES
      Place additional notes here.

      .LINK
      URLs to related sites
      The first link is opened by Get-Help -Online Write-Log

      .INPUTS
      List of input types that are accepted by this function.

      .OUTPUTS
      List of output types produced by this function.
  #>


  param (
        [Parameter(Mandatory,HelpMessage='Add help message for user')]
        [array]$LogOutput
  )
  $currentDate = (Get-Date -UFormat '%d-%m-%Y')
  $currentTime = (Get-Date -UFormat '%T')
  $logOutput = $logOutput -join (' ')
  ('[{0} {1}] {2}' -f $currentDate, $currentTime, $logOutput) | Out-File -FilePath $LogFile -Append
}

    function script:loginfo {
      <#
        .SYNOPSIS
        Describe purpose of "loginfo" in 1-2 sentences.

        .DESCRIPTION
        Add a more complete description of what the function does.

        .PARAMETER message
        Describe parameter -message.

        .EXAMPLE
        loginfo -message Value
        Describe what this call does

        .NOTES
        Place additional notes here.

        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online loginfo

        .INPUTS
        List of input types that are accepted by this function.

        .OUTPUTS
        List of output types produced by this function.
      #>

      # Function to easy use write-log
        param (
            
            [Parameter(Mandatory,HelpMessage='Add help message for user')]
            [string]$message
        )
        
        Write-Verbose -Message $message -Verbose
        Write-Log -LogOutput $message
}

# Function to determine difference between service before and after restart

Function Get-Uptime{
    Param(
        [Parameter(Mandatory=$false)]
        [string]$ComputerName,
        [Parameter(Mandatory=$false)]
        [switch]$Since
    )
 
    # Check if computer name is supplied, if not set default to local machine
    IF([string]::IsNullOrEmpty($ComputerName)){
        $ComputerName = $env:COMPUTERNAME
    }
 
    # Calculate last boot time
    IF($Since.IsPresent){
        [System.Management.ManagementDateTimeconverter]::ToDateTime($(Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem  | Select-Object -ExpandProperty LastBootUpTime))
    }ELSE{
        (Get-Date) - [System.Management.ManagementDateTimeconverter]::ToDateTime($(Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem  | Select-Object -ExpandProperty LastBootUpTime)) #| FT Days,Hours,Minutes,Seconds -AutoSize
    }
 }


function get-diffservices {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $computername
    )
     
    # Get the list of services post reboot
    $previousStatus = (get-service -ComputerName $computername | Where-Object{$_.Status -eq "Running"} | Select-Object -Property Name).Name
    
    # checking if reboot is required

    $rebootrequired=get-systemreboot -servername $computername

    # Get the list of services post reboot

        if($rebootrequired -eq $true -and $pendingrebootcounter -lt 1){
            # reboot is required
            Restart-Computer -Wait -For PowerShell -ComputerName $computername -Credential $credential -Timeout 600 -Delay 5 -Force
            
            # list of services post reboot
            $poststatus=(get-service -ComputerName $computername | Where-Object{$_.Status -eq "Running"} | Select-Object -Property Name).Name
    
            # Compare previous and current status
            if($null -eq (($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ",")){
            $difference = "No difference"
            }
            else{
                $difference = ($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ","
            }
            $uptime=Get-Uptime -ComputerName $computername -Since
        }
        else{
        $difference="No reboot required"
        $uptime="No reboot"
        }
    
        # custom object to take the output

    [PSCustomObject]@{
        Difference_services= $difference
        Reboot_time=$uptime
    }
}

Function get-systemreboot{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]
        $servername
    )

Invoke-Command -ComputerName $servername -ScriptBlock { 
     if (Get-ChildItem "HKLM:\Software\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending" -EA Ignore) { return $true }
     if (Get-Item "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired" -EA Ignore) { return $true }
     if (Get-ItemProperty "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager" -Name PendingFileRenameOperations -EA Ignore) { return $true }
     try { 
       $util = [wmiclass]"\\.\root\ccm\clientsdk:CCM_ClientUtilities"
       $status = $util.DetermineIfRebootPending()
       if(($null -ne $status) -and $status.RebootPending){
         return $true
         $global:pendingrebootcounter++
       }
     }catch{
     
     }
     return $false
    }
}

function Import-LocalModuleToRemoteSession
{
    [CmdletBinding()]
    param(
        # Module to import
        [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Mandatory)]
        [System.Management.Automation.PSModuleInfo]$ModuleInfo,

        # PSSession to import module to
        [Parameter(Mandatory)]
        [System.Management.Automation.Runspaces.PSSession]
        $Session,

        # Override temporary folder location for module to be copied to on remote machine 
        [string]
        $SessionModuleFolder=$null,

        [switch]
        $Force,

        [switch]
        $SkipDeleteModuleAfterImport

    )

    begin{
        function New-TemporaryDirectory {
            $parent = [System.IO.Path]::GetTempPath()
            [string] $name = [System.Guid]::NewGuid()
            New-Item -ItemType Directory -Path (Join-Path $parent $name)
        }
    }

    process{
        
        if( [string]::IsNullOrWhiteSpace($SessionModuleFolder) ){
            Write-Verbose "Creating temporary module folder"
            $item = Invoke-Command -Session $Session -ScriptBlock ${function:New-TemporaryDirectory} -ErrorAction Stop
            $SessionModuleFolder = $item.FullName
            Write-Verbose "Created temporary folder $SessionModuleFolder"
        }

        $directory = (Join-Path -Path $SessionModuleFolder -ChildPath $ModuleInfo.Name)
        Write-Verbose "Copying module $($ModuleInfo.Name) to remote folder: $directory"
        Copy-Item `
            -ToSession $Session `
            -Recurse `
            -Path $ModuleInfo.ModuleBase `
            -Destination $directory
        
        Write-Verbose "Importing module on remote session @ $directory "

        try{
            Invoke-Command -Session $Session -ErrorAction Stop -ScriptBlock `
            { 
                Get-ChildItem (Join-Path -Path ${Using:directory} -ChildPath "*.psd1") `
                    | ForEach-Object{ 
                        Write-Debug "Importing module $_"
                        Import-Module -Name $_ #-Force:${Using:Force}
                    }
                
                    if( -not ${Using:SkipDeleteModuleAfterImport} ){
                        Write-Debug "Deleting temporary module files: $(${Using:directory})"
                        Remove-Item -Force -Recurse ${Using:directory}
                    }
            }
        }
        catch
        {
            Write-Error "Failed to import module on $Session with error: $_"
        }
    }
}


# Main

New-NetFirewallRule -DisplayName "Allow PSWindowsUpdate" -Direction Inbound -Program "%SystemRoot%\System32\dllhost.exe" -RemoteAddress Any -Action Allow -LocalPort 'RPC' -Protocol TCP

$stopwatch=[System.Diagnostics.Stopwatch]::StartNew() ;
$Computers | foreach-object -Parallel {
    Write-Host "Patching $_" -ForegroundColor "green"

    If (test-connection -ComputerName $_ -Count 1 -Quiet)
    {
        write-host "Connection to $_ is successful" -ForegroundColor "green"

       # Try {
            
            # Initializing counter variable for each computer
            $counter=@{}    

            # Adding computer name to the counter variable with counter 0
            $counter.add('$_',0)

            # Copying local module to remote session
            Copy-Item -Path "C:\Users\novaprime\Documents\PSWindowsUpdate" -Destination "\\$_\c$\Windows\system32\WindowsPowerShell\v1.0\Modules" -Recurse -force;
            # write-host "Copying module to $_" -ForegroundColor "green"
            
            if($? -eq $false){
                write-host "Failed to copy module to $_" -ForegroundColor "red"
                break;
            }
            
            # Starting do loop

            do {
                # Getting the counter value
                write-host "starting do loop for $_" -ForegroundColor "green"
                write-host '{0} is the counter value for {1}' -f $counter['$_'],$_ -ForegroundColor "green"

                Invoke-Command -ComputerName $_ -ScriptBlock {
                    Import-Module 'C:\Windows\System32\WindowsPowerShell\v1.0\Modules\PSWindowsUpdate\2.2.0.2\PSWindowsUpdate.psd1';
                } -ErrorAction SilentlyContinue

                if($? -eq $false){
                    write-host "Failed to import module on $_" -ForegroundColor "red"
                    break;
                }

                # checking if there are any windows update to isntall

                if(!(get-windowsupdate -ComputerName $_ ))
                {
                    write-host "There are no windows updates to install on $_" -ForegroundColor "green"
                    break;
                }

                Install-WindowsUpdate -ComputerName $_ -AcceptAll -IgnoreReboot -Confirm:$false ;

                #Get-WUServiceManager -ComputerName $_ | Where-Object {$_.IsDefaultAUService -eq "true"} | Select-Object ComputerName,IsDefaultAUService,Name;
    
                #Get-WUHistory -ComputerName $_ | Where-Object { (get-date).adddays((-4)) -le $_.installedon} | Format-Table ;

            if((Get-WURebootStatus -ComputerName $_ | Select-Object RebootRequired).rebootrequired -eq $true) {
                
                if($counter['$_'] -eq "0"){
        
                Write-Host "Reboot required on $_" -ForegroundColor "red";
                
                $previousStatus = (get-service -ComputerName $computername | Where-Object{$_.Status -eq "Running"} | Select-Object -Property Name).Name
                
                Restart-Computer -Wait -For PowerShell -ComputerName $_ -Credential $credential -Timeout 600 -Delay 5 -Force;
                
                $counter['$_']++;
                
                $poststatus=(get-service -ComputerName $computername | Where-Object{$_.Status -eq "Running"} | Select-Object -Property Name).Name;
    
                # Compare previous and current status
                if($null -eq (($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ",")){
                $difference = "No difference"
                }
                else{
                $difference = ($previousStatus | Where-Object {$poststatus -notcontains $_}) -join ","
                }
                $uptime=[System.Management.ManagementDateTimeconverter]::ToDateTime($(Get-WmiObject -ComputerName $ComputerName -Class Win32_OperatingSystem  | Select-Object -ExpandProperty LastBootUpTime))
                
                <#[PSCustomObject]@{
                    Difference_services= $difference
                    Reboot_time=$uptime
                }#>
            }
            else {
                write-host "another Reboot required - so skipping on $_" -ForegroundColor "green";
            }
        }
        else{
            Write-Host "Reboot not required on $_" -ForegroundColor "green";
        }

    } while ($counter['$_'] -lt "2")

            $status = "Patched"
            $issue="No Error"

        } Catch {

            $status = "Failed"
            $issue=$($Error[0].exception.message)

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        $status = "Unreachable"
        $issue="Destination host is not reachable"
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


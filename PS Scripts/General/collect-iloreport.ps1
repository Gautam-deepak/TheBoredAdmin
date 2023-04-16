<#

Purpose:        This script collects and stores the configuration data from a HPE iLO as a series of
                PowerShell variables, so that the data can be parsed without direct access to the iLO.

Author:         Martin Cooper
Version:        0.1.4
Date:           June 2019
Twitter:        @mc1903
Github:         mc1903


Tested with an iLO4, but should work for iLO3 & iLO5 as well.

It is preferable to run this script with the server booted in to it's
Operating System, as this will allow for the most data to be collected.

Run this script from a remote machine.

Requires PowerShell 5.1 & HPEiLOCmdlets Module (Available from the PowerShell Gallery)

The HPEiLOCmdlets Module can be tricky to install - the following works for me each time!

    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
    Install-PackageProvider -Name NuGet -Force -MinimumVersion 2.8.5.201
    Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
    Install-PackageProvider -Name PowerShellGet -Force -RequiredVersion 2.0.1
    Import-PackageProvider -Name PowerShellGet -Force -RequiredVersion 2.0.1
    Install-Module -Name HPEiLOCmdlets
        (The HPEiLOCmdlets EULA should popup if all installs OK - Answer 'Yes to All')

Usage:

PS C:\> .\Collect_HPE_iLO_Data.ps1 -iLOTarget 10.1.1.102 -iLOUser Administrator -iLOPwd XHIU21AF

NOTE: You can omit the 'iLOPwd' parameter to be prompted to enter the password interactivly.

#>

#requires -Modules @{ModuleName="HPEiLOCmdlets";ModuleVersion="2.1.0.0"}

#region Script Parameters
Param(
    [Parameter(Position = 0, Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String[]]$iLOTarget,
    [Parameter(Position = 1, Mandatory = $True)]
    [ValidateNotNullOrEmpty()]
    [String]$iLOUser,
    [Parameter(Position = 2, Mandatory = $False)]
    [ValidateNotNullOrEmpty()]
    [String]$iLOPwd
)
#endregion Script Parameters

#region Check Credentials
If ($iLOUser -and $iLOPwd) {
    $iLOSecPwd = ConvertTo-SecureString $iLOPwd -AsPlainText -Force
    $iLOCredentials = New-Object System.Management.Automation.PSCredential ($iLOUser, $iLOSecPwd)
}
Elseif ($iLOUser -and !($Password)) {
    $iLOCredentials = Get-Credential -Credential $iLOUser
}
#endregion Check Credentials

#region Create iLO Connection
$HPEiLOConnection = Connect-HPEiLO -Credential $iLOCredentials -IP $iLOTarget -DisableCertificateAuthentication -ErrorAction SilentlyContinue
    If (!$HPEiLOConnection) {
        Write-Host "`nUnable to connect to the iLO. Please check your IP/FQDN, Username &/or Password"
        Remove-Variable -Name * -ErrorAction SilentlyContinue
        Exit
    }
Clear-Host
#endregion Create iLO Connection

#region Main Script
$GetCmds = Get-Command -Verb Get -Module HPEiLOCmdlets
ForEach ($Cmd in $GetCmds) {
    Write-Output "Executing Command $($Cmd.name)"
    $Cmdname = "$Cmd -Connection `$HPEiLOConnection"
        try
        {
            $Result = Invoke-Expression $Cmdname -ErrorAction SilentlyContinue
        }
        catch
        { 
            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
        }
    New-Variable -Name "$($Cmd.name.TrimStart("Get-"))" -Value $Result -Force
}

$HPEiLOInfo = Get-HPEiLOInfo $iLOTarget -DisableCertificateAuthentication
$HPEiLOHostData = Get-HPEiLOHostData -Connection $HPEiLOConnection | Read-HPEiLOSMBIOSRecord
$HPEiLOHostDataBIOSInformation = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "BIOSInformation"
$HPEiLOHostDataSystemInformation = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "SystemInformation"
$HPEiLOHostDataBaseboardInformation = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "BaseboardInformation"
$HPEiLOHostDataSystemEnclosureOrChassis = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "SystemEnclosureOrChassis"
$HPEiLOHostDataProcessorInformation = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "ProcessorInformation"
$HPEiLOHostDataSystemSlots = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "SystemSlots"
$HPEiLOHostDataPhysicalMemoryArray = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "PhysicalMemoryArray"
$HPEiLOHostDataMemoryDevice = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "MemoryDevice"
$HPEiLOHostDataSystemPowerSupply = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "SystemPowerSupply"
$HPEiLOHostDataOnboardDevicesExtendedInformation = $($HPEiLOHostData.SMBIOSRecord) | Where-Object -Property StructureName -eq "OnboardDevicesExtendedInformation"
$HPEiLOFirmwareInventoryPriSysROM = $($HPEiLOFirmwareInventory.FirmwareInformation) | Where-Object {$_.FirmwareName -eq "System ROM"}
$HPEiLOFirmwareInventoryRedSysROM = $($HPEiLOFirmwareInventory.FirmwareInformation) | Where-Object {$_.FirmwareName -eq "Redundant System ROM"}
$HPEiLOPowerSupplySummary = $($HPEiLOPowerSupply.PowerSupplySummary)
$HPEiLOMemorySlotInfo = $($HPEiLOMemoryInfo.MemoryDetails.MemoryData)
$HPEiLONICInfoActivePort = $($HPEiLONICInfo.EthernetInterface) | Where-Object {$_.Status -eq "OK"}
$HPEiLONICNetAdapters = $($HPEiLONICInfo.NetworkAdapter)
$HPEiLOSmartArrayStorageControllers = $($HPEiLOSmartArrayStorageController.Controllers)
$HPEiLOSmartArrayStorageControllersPD = $($HPEiLOSmartArrayStorageControllers.PhysicalDrives)
$HPEiLOSmartArrayStorageControllersLD = $($HPEiLOSmartArrayStorageControllers.LogicalDrives)
$HPEiLOSmartArrayStorageControllersUD = $($HPEiLOSmartArrayStorageControllers.UnconfiguredDrives)
$HPEiLOSmartArrayStorageControllersSE = $($HPEiLOSmartArrayStorageControllers.StorageEnclosures)
$HPEiLOEventLogAll = $($HPEiLOEventLog.EventLog)
$HPEiLOEventLogInformational = $($HPEiLOEventLog.EventLog) | Where-Object {$_.Severity -eq "Informational"}
$HPEiLOEventLogCaution = $($HPEiLOEventLog.EventLog) | Where-Object {$_.Severity -eq "Caution"}
$HPEiLOEventLogCritical = $($HPEiLOEventLog.EventLog) | Where-Object {$_.Severity -eq "Critical"}
$HPEiLOEventLogUnknown = $($HPEiLOEventLog.EventLog) | Where-Object {$_.Severity -eq "Unknown"}
$HPEiLOIMLAll = $($HPEiLOIML.IMLLog)
$HPEiLOIMLInformational = $($HPEiLOIML.IMLLog) | Where-Object {$_.Severity -eq "Informational"}
$HPEiLOIMLCaution = $($HPEiLOIML.IMLLog) | Where-Object {$_.Severity -eq "Caution"}
$HPEiLOIMLCritical = $($HPEiLOIML.IMLLog) | Where-Object {$_.Severity -eq "Critical"}
$HPEiLOIMLRepaired = $($HPEiLOIML.IMLLog) | Where-Object {$_.Severity -eq "Repaired"}
$HPEiLOIMLUnknown = $($HPEiLOIML.IMLLog) | Where-Object {$_.Severity -eq "Unknown"}

$iLOVersion = $($HPEiLOInfo.Manager.ManagerType) -replace (' ')
$iLOHostName = $($HPEiLOInfo.Manager.HostName)
$DateTimeStamp = Get-Date -uformat %Y%m%d-%H%M%S
$Filename = "$PSScriptRoot\HPE_$($HPEiLOConnection.ServerModel)_$($HPEiLOConnection.ServerGeneration)_$($iLOVersion)_$($DateTimeStamp).xml"
Get-Variable HPEiLO* | Export-Clixml $Filename -Depth 50
Write-Host "`nThe iLO data for $iLOHostName has been saved as $Filename"
Write-Host "`nPlease upload this .xml file to my Dropbox @ https://www.dropbox.com/request/ON5dRs7QWlS1mO0vLpJf"
Write-Host "`nThank you for contributing to my project. @mc1903"
Disconnect-HPEiLO -Connection $HPEiLOConnection
Remove-Variable -Name * -ErrorAction SilentlyContinue
#endregion Main Script
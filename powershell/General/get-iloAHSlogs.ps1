####################################################################
#Download AHS log.
####################################################################

<#
.Synopsis
    This script saves the AHS Log. 

.DESCRIPTION
    This script saves the AHS Log at the specified location for the given number of days.
	
	The cmdlets used from HPEiLOCmdlets module in the script are as stated below:
	Enable-HPEiLOLog, Connect-HPEiLO, Save-HPEiLOAHSLog, Disconnect-HPEiLO, Disable-HPEiLOLog

.PARAMETER FileLocation
        The directory location where AHS log file gets created.

.PARAMETER ContactName
        Specifies the contact person name that gets inserted in the AHS log header.

.PARAMETER CompanyName
        Specifies the company name that gets inserted in the AHS log header.
        
.PARAMETER CaseNumber
        Specifies the case number that gets inserted in the AHS log header. Accepts upto 14 characters.

.PARAMETER Days
        This parameter when given downloads the most recent N days of the AHS log. The default value is 1.

.PARAMETER Email
        Specifies the email id of the contact person that gets inserted in the AHS log header.

.PARAMETER PhoneNumber
        Specifies the phone number of the contact person that gets inserted in the AHS log header. Accepts upto 39 characters.

.EXAMPLE
    
    PS C:\HPEiLOCmdlets\Samples\> .\SaveAHSLog.ps1 -FileLocation "C:\iLO" -Days 2 -CompanyName "HPE"

    This script takes input parameter for FileLocation, Days and the Company Name.
 
.INPUTS
	iLOInput.csv file in the script folder location having iLO IPv4 address, iLO Username and iLO Password.

.OUTPUTS
    None (by default)

.NOTES
	Always run the PowerShell in administrator mode to execute the script.
	
   Company : Hewlett Packard Enterprise
    Version : 3.0.0.0
    Date    : 01/15/2020

.LINK
    http://www.hpe.com/servers/powershell
#>

#Command line parameters
Param(

    [Parameter(Mandatory=$true)]
    [string[]]$FileLocation, 
    [Parameter(Mandatory=$true)]
    [UInt32[]]$Days,  
    [string[]]$CaseNumber,
    [string[]]$CompanyName,
    [string[]]$ContactName,
    [string[]]$Email,
    [string[]]$PhoneNumber
    )

try
{
    $path = Split-Path -Parent $PSCommandPath
    $path = join-Path $path "\iLOInput.csv"
    $inputcsv = Import-Csv $path
	if($inputcsv.IP.count -eq $inputcsv.Username.count -eq $inputcsv.Password.count -eq 0)
	{
		Write-Host "Provide values for IP, Username and Password columns in the iLOInput.csv file and try again."
        exit
	}

    $notNullIP = $inputcsv.IP | Where-Object {-Not [string]::IsNullOrWhiteSpace($_)}
    $notNullUsername = $inputcsv.Username | Where-Object {-Not [string]::IsNullOrWhiteSpace($_)}
    $notNullPassword = $inputcsv.Password | Where-Object {-Not [string]::IsNullOrWhiteSpace($_)}
	if(-Not($notNullIP.Count -eq $notNullUsername.Count -eq $notNullPassword.Count))
	{
        Write-Host "Provide equal number of values for IP, Username and Password columns in the iLOInput.csv file and try again."
        exit
	}
}
catch
{
    Write-Host "iLOInput.csv file import failed. Please check the file path of the iLOInput.csv file and try again."
    Write-Host "iLOInput.csv file path: $path"
    exit
}

Clear-Host

# script execution started
Write-Host "****** Script execution started ******`n" -ForegroundColor Yellow
#Decribe what script does to the user

Write-Host "This script downloads the AHS log in the given location for the given server.`n"

#Load HPEiLOCmdlets module
$InstalledModule = Get-Module
$ModuleNames = $InstalledModule.Name

if(-not($ModuleNames -like "HPEiLOCmdlets"))
{
    Write-Host "Loading module :  HPEiLOCmdlets"
    Import-Module HPEiLOCmdlets
    if(($(Get-Module -Name "HPEiLOCmdlets")  -eq $null))
    {
        Write-Host ""
        Write-Host "HPEiLOCmdlets module cannot be loaded. Please fix the problem and try again"
        Write-Host ""
        Write-Host "Exit..."
        exit
    }
}
else
{
    $InstallediLOModule  =  Get-Module -Name "HPEiLOCmdlets"
    Write-Host "HPEiLOCmdlets Module Version : $($InstallediLOModule.Version) is installed on your machine."
    Write-host ""
}

$Error.Clear()

#Enable logging feature
Write-Host "Enabling logging feature" -ForegroundColor Yellow
$log = Enable-HPEiLOLog
$log | fl

if($Error.Count -ne 0)
{ 
	Write-Host "`nPlease launch the PowerShell in administrator mode and run the script again." -ForegroundColor Yellow 
	Write-Host "`n****** Script execution terminated ******" -ForegroundColor Red 
	exit 
}	

try
{
	$ErrorActionPreference = "SilentlyContinue"
	$WarningPreference ="SilentlyContinue"

    [bool]$isParameterCountEQOne = $false;

    foreach ($key in $MyInvocation.BoundParameters.keys)
    {
        $count = $($MyInvocation.BoundParameters[$key]).Count
        if($count -ne 1 -and $count -ne $inputcsv.Count)
        {
            Write-Host "The input paramter value count and the input csv IP count does not match. Provide equal number of IP's and parameter values." -ForegroundColor Red    
            exit;
        }
        elseif($count -eq 1)
        {
            $isParameterCountEQOne = $true;
        }

    }

    $connection = Connect-HPEiLO -IP $inputcsv.IP -Username $inputcsv.Username -Password $inputcsv.Password -DisableCertificateAuthentication
	
	$Error.Clear()
    
    if($Connection -eq $null)
    {
        Write-Host "`nConnection could not be established to any target iLO.`n" -ForegroundColor Red
        $inputcsv.IP | fl
        exit;
    }

    if($Connection.count -ne $inputcsv.IP.count)
    {
        #List of IP's that could not be connected
        Write-Host "`nConnection failed for below set of targets" -ForegroundColor Red
        foreach($item in $inputcsv.IP)
        {
            if($Connection.IP -notcontains $item)
            {
                $item | fl
            }
        }

        #Prompt for user input
        $mismatchinput = Read-Host -Prompt 'Connection object count and parameter value count does not match. Do you want to continue? Enter Y to continue with script execution. Enter N to cancel.'
        if($mismatchinput -ne 'Y')
        {
            Write-Host "`n****** Script execution stopped ******" -ForegroundColor Yellow
            exit;
        }
    }

    foreach($connect in $connection)
    {
        $index = $inputcsv.IP.IndexOf($connect.IP)
            Write-Host "`nDownloading AHS log for $($connect.IP) at the specified location." -ForegroundColor green
        $appendText = [string]::Empty
        foreach ($key in $MyInvocation.BoundParameters.keys)
        {
            $value = $($MyInvocation.BoundParameters[$key])
            if($value.Count -ne 1){
            $appendText +=" -"+$($key)+" "+$value[$index] }
            else
            {  $appendText +=" -"+$($key)+" "+$value }
        }
        $cmdletName = "Save-HPEiLOAHSLog"
        $expression = $cmdletName + " -connection $" + "connect" +$appendText
        $output = Invoke-Expression $expression

        if($output.StatusInfo -ne $null)
        {   
            $message = $output.StatusInfo.Message; 
            if($output.Status -eq "ERROR")
            {
                Write-Host "`nDownloading AHS failed for $($output.IP): "$message -ForegroundColor red
            }
        }
    }

}
 catch
 {
 }
finally
{
    if($connection -ne $null)
    {
        #Disconnect 
		Write-Host "Disconnect using Disconnect-HPEiLO `n" -ForegroundColor Yellow
		$disconnect = Disconnect-HPEiLO -Connection $Connection
		$disconnect | fl
		Write-Host "All connections disconnected successfully.`n"
    }  
	if($Error.Count -ne 0 )
    {
        Write-Host "`nScript executed with few errors. Check the log files for more information.`n" -ForegroundColor Red
    }

	#Disable logging feature
	Write-Host "Disabling logging feature`n" -ForegroundColor Yellow
	$log = Disable-HPEiLOLog
	$log | fl

    Write-Host "`n****** Script execution completed ******" -ForegroundColor Yellow
} 
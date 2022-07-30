#Creating logoutput and filenames
$LogFolder = "C:\Temp\computer-rename-logs"
$LogFile = $LogFolder + "\" + (Get-Date -UFormat "%d-%m-%Y") + ".log"

Function Write-Log
{
	param (
        [Parameter(Mandatory=$True)]
        [array]$LogOutput
	)
	$currentDate = (Get-Date -UFormat "%d-%m-%Y")
	$currentTime = (Get-Date -UFormat "%T")
	$logOutput = $logOutput -join (" ")
	"[$currentDate $currentTime] $logOutput" | Out-File $LogFile -Append
}

# Usage

 try{
    8/0
    }
    Catch{
    Write-Output tatti
    }

# Set log file path
$logFile = "C:\temp\files\$env:computername-process.log"

Function Write-Log {
    param(
        [Parameter(Mandatory = $true)][string] $message,
        [Parameter(Mandatory = $false)]
        [ValidateSet("INFO","WARN","ERROR")]
        [string] $level = "INFO"
    )

    # Create timestamp
    $timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")

    # Append content to log file
    Add-Content -Path $logFile -Value "$timestamp [$level] - $message"
}

Write-Log -level ERROR -message "String failed to be a string"
<# Tasks to be done in the script


1. Install gaurdicore , sapphire, SOC , Opsramp
2. Rename local admin to LPUADM#
3. Add the hostname to WSUS GPO - Domain_UPL_WSUS_SERVERS

#>

# Copy the .exe from central location to the build directory and install them

Add-Type -AssemblyName System.IO.Compression.FileSystem

$zipfilehash="66E358F362261095FFF9E8E2397F4A24A66D5513E532D7803378103255D22A8F"
$robocopyPath = "C:\Windows\system32\robocopy.exe"
$batches=@("C:\temp\essential_software\soc.bat", "C:\temp\essential_software\gaurdicore_script.bat")
$executables=@("C:\temp\essential_software\sapphire.exe", "C:\temp\essential_software\Opsrampagent.exe")
$sourceDir="\\novaprime.in\netlogon\software\"
$destinationdir="C:\temp"
$file="C:\temp\essential_software.zip"
$unzipfolder="C:\temp\essential_software\"
$ErrorActionPreference="Stop"

if(!(Test-Path $destinationdir)){
    New-Item -Path "C:\" -Name "temp" -ItemType Directory | Out-Null 
}


#function to use robocopy with powershell to copy files

function copy-files {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, `
        ValueFromPipelineByPropertyName=$true, HelpMessage="Source directory")]
        [string]
        $sourceDir,
        [Parameter(Mandatory=$true, Position=1, ValueFromPipeline=$true, `
        ValueFromPipelineByPropertyName=$true, HelpMessage="Destination directory")]
        [string]
        $destDir
    )
    
    begin {
        write-host "Checking if zip file exist in the source directory" -ForegroundColor Green
        if(test-path $file){
            write-host "Zip file exists" -ForegroundColor Green
            break
        }
    }
    
    process {
        try {
            $arguments="$sourceDir $destinationdir /MIR /ZB /nooffload"
            Start-Process -FilePath $robocopyPath -ArgumentList $arguments -Wait -PassThru -NoNewWindow | Out-Null
        }
        catch {
            Write-Host "Error copying Zip : $($Error[0].Exception.Message)" -ForegroundColor Red
            write-host "Please rerun script again, if error happens copy zip file manually" -ForegroundColor Red
            break;
        }
        
    }
    end {
        Write-Host "Zip File successfully copied to $($destDir)" -ForegroundColor Green
        if(compare-filehash -file $file -hash $zipfilehash){
            write-host "Zip file hash matches" -ForegroundColor Green
        }
    }
}

function Unzip
{   
    [cmdletbinding()]
    param(
        # Parameter help description
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $zipfile, 
        [Parameter(Mandatory=$true, Position=1)]
        [string]
        $outpath,
        [Parameter(Mandatory=$true, Position=2)]
        [string]
        $unzipfolder)

    try {
        if(!(test-path $unzipfolder)){
            [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
            Write-Host "Unzipped successfully" -ForegroundColor Green
        }
        else {
            write-host "Zip file already unzipped" -ForegroundColor Red
        }
    }
    catch {
        write-host "Error unzipping : $($Error[0].exception.Message)" -ForegroundColor Red
    }    
}
function get-softwareinstallstatus {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, `
        ValueFromPipelineByPropertyName=$true, HelpMessage="Source directory")]
        [string]
        $exitcode,
        [parameter(Mandatory=$false, Position=0, ValueFromPipeline=$true, `
        ValueFromPipelineByPropertyName=$true, HelpMessage="Source directory")]
        [string]
        $Name
    )
    
        if ($exitcode -eq 0) {
            Write-Host ('{0} installed successfully' -f $name) -ForegroundColor Green
        }
        else {
            Write-Host ('Error installing {0}' -f $name) -ForegroundColor Red
        }
}
function compare-filehash {
    [cmdletbinding()]
    param (
        [Parameter(Mandatory=$true, Position=0)]
        [string]
        $filepath,
        [Parameter(Mandatory=$true, Position=1)]
        [string]
        $hashvalue
    )
    
    #calculate hash of remote file
    try{
        $remoteHash=Get-FileHash -Path $filepath -Algorithm SHA256 | `
        Select-Object Hash -ExpandProperty Hash
        if ($hashvalue -eq $remoteHash) {
            return $true
        }
        else {
            return $false
        }
    }
    catch{
        return $false
    }
}

function install-executables {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, `
        ValueFromPipelineByPropertyName=$true, HelpMessage="Source directory")]
        [string]
        $path
    )
    try {
        $Process=Start-Process -Wait -FilePath $path -ArgumentList '/Q' -passthru -NoNewWindow | Out-Null
        get-softwareinstallstatus $Process.ExitCode -Name $path.Split("\")[3]
    }
    catch {
        $err=$Error[0].message
        write-host ('Error installing {0} : {1}' -f $err,$path.Split("\")[3]) -ForegroundColor Red
    }
}

function install-batch {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, `
        ValueFromPipelineByPropertyName=$true, HelpMessage="Source directory")]
        [string]
        $path
    )
    try {
        $Process=Start-Process -FilePath $path -Wait -NoNewWindow -PassThru | Out-Null
        get-softwareinstallstatus $Process.ExitCode -Name $path.Split("\")[3].Split(".")[0]
    }
    catch {
        $err=$Error[0].message
        write-host ('Error installing {0} : {1}' -f $err,$path.Split("\")[3].Split(".")[0]) -ForegroundColor Red
    }
}


#Main 
copy-files -sourceDir $sourceDir -destDir $destinationdir
Unzip $file $destinationdir $unzipfolder
$batches | ForEach-Object {install-batch $_}
$executables | ForEach-Object {install-executables $_}
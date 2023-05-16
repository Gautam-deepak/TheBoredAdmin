# get license status of remote machines

#[System.Management.ManagementDateTimeConverter]::ToDateTime($date).ToUniversalTime();

#variables
    
$lstat = DATA {

    ConvertFrom-StringData -StringData @’
    
    0 = Unlicensed
    
    1 = Licensed
    
    2 = OOB Grace
    
    3 = OOT Grace
    
    4 = Non-Genuine Grace
    
    5 = Notification
    
    6 = Extended Grace
‘@
    
    }

$Computers = Get-Content "C:\computerlist.txt"
$ErrorActionPreference="Stop"

$results = foreach ($computer in $computers)
{
    Write-Host "Working on $computer" -ForegroundColor "green"

    If (test-connection -ComputerName $computer -Count 1 -Quiet)
    {
        Try {
            $compdetails=@(Get-CimInstance -computername $computer Win32_OperatingSystem | `
            Select-Object Csname,Caption, Version, OSArchitecture)

            $licenseinfo=@(Get-CimInstance SoftwareLicensingProduct -ComputerName $computer | `
            Where-Object {$_.PartialProductKey} | `
            where-object {$_.name -like "*windows*"} | `
            Select-Object ApplicationId, @{N=”LicenseStatus”; E={$lstat[“$($_.LicenseStatus)”]} })
            
            $OS=$compdetails.Caption
            $version = $compdetails.Version
            $OSArch=$compdetails.OSArchitecture
            $licenseStatus=$licenseinfo.LicenseStatus
            $productKey=$licenseinfo.ApplicationId
            $expirationDate=Invoke-Command -ComputerName $computer -ScriptBlock { ((cscript C:\Windows\System32\slmgr.vbs /xpr 2>&1)[4]).trim() }
            $status="success"
            $issue="No Issue"

        } Catch {
            $OS="unknown"
            $version="unknown"
            $OSArch="unknown"
            $productKey="unknown"
            $licenseStatus="unknown"
            $expirationDate="unknown"
            $status = "Failed"
            $issue=$($Error[0].exception.message)

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        $OS="unknown"
        $version="unknown"
        $OSArch="unknown"
        $productKey="unknown"
        $licenseStatus="unknown"
        $expirationDate="unknown"
        $status = "Unreachable"
        $issue="Destination host is not reachable"
    }
    
    [pscustomobject]@{
        'Computer'=$computer
        'OS'=$OS
        'OS Version'=$version
        'OS Architecture'=$OSArch
        'License Status'=$licenseStatus
        'Product Key'=$productKey
        'Expiration Date'=$expirationDate
        'Success'=$status
        'Issue'=$issue
    }
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force




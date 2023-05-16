# Functions

function ConvertFromDN {
    param (
        [Parameter(Mandatory, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$dn
    )
    process {
        if ($dn) {
            $d = ''; $p = '';
            $dn -split '(?<!\\),' | ForEach-Object { if ($_ -match '^DC=') { $d += $_.Substring(3) + '.' } else { $p = $_.Substring(3) + '\' + $p } }
            Write-Output ($d.Trim('.') + '\' + ($p.TrimEnd('\') -replace '\\,',','))
        }
    }
}

function ConvertFrom-CanonicalUser {
    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [string]$CanonicalName
    )
    process {
        $obj = $CanonicalName.Split('/')
        [string]$DN = 'CN=' + $obj[$obj.count - 1]
        for ($i = $obj.count - 2; $i -ge 1; $i--) { $DN += ',OU=' + $obj[$i] }
        $obj[0].split('.') | ForEach-Object { $DN += ',DC=' + $_ }
        return $DN
    }
}

function ConvertFromDN {
    param (
        [Parameter(Mandatory, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]$dn
    )
    process {
        if ($dn) {
            $d = ''; $p = '';
            $dn -split '(?<!\\),' | ForEach-Object { if ($_ -match '^DC=') { $d += $_.Substring(3) + '.' } else { $p = $_.Substring(3) + '\' + $p } }
            Write-Output ($d.Trim('.') + '\' + ($p.TrimEnd('\') -replace '\\,',','))
        }
    }
}

# move AD computer to different OU

$csv=import-csv -Path "C:\temp\hostname.csv"

$results=foreach ($item in $csv)
{
    Try {
        
        Move-ADObject -Identity (Get-ADComputer -Identity $item.hostname.trim()).distinguishedname -TargetPath $item.OU

        $status="Moved"
        $issue="none"
        

    } Catch {

        $status="Not Moved"
        $issue=($($Error[0]).Exception.Message)
    }

    Finally{
        $Error.Clear()
    }

[pscustomobject]@{
    'Hostname'=$item.Hostname
    'OU'=$item.OU
    'Status'=$status
    'Error'=$issue
    }
}

$results | Export-Csv c:\temp\results.csv -NoTypeInformation -Force
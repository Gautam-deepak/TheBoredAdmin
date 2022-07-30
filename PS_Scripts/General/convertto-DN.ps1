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
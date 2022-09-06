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
        [string]$DN = 'OU=' + $obj[$obj.count - 1]
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


# move AD user to different OU

$users=import-csv -Path "C:\temp\users.csv"

$results=foreach ($User in $Users)
{
    Try {
        
        Set-ADObject -Identity (Get-ADUser -Identity $User.ugdn.trim()) -ProtectedFromAccidentalDeletion $false 
        Move-ADObject -Identity (Get-ADUser -Identity $user.ugdn.Trim()).distinguishedname -TargetPath $user.ou -Confirm:$false

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
    'UGDN'=$user.ugdn
    'OU'=$User.OU
    'Status'=$status
    'Error'=$issue
    }
    
}

$results | Export-Csv c:\temp\results.csv -NoTypeInformation -Force
$server=Get-Content -Path C:\Temp
$ErrorActionPreference="stop"

$final=foreach ($item in $server) {
    try {
        $result=(get-adcomputer $item).enabled
        if ($result -eq $true) {
            $Exist="True"
            $Active="True"
        }
        elseif ($result -eq $false) {
            $Exist="True"
            $Active="False"
        }
    }
    catch {
        $Exist="False"
        $Active="False"
    }
    [PSCustomObject]@{
        'Computer' = $item
        'Exist'=$Exist
        'Active'=$Active
    }
}

$final | export-csv -notypeinformation -path c:\temp\ -force
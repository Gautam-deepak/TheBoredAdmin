function get-Result {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$result,

        [Parameter(Mandatory)]
        [string]$string

    )

    If($result -eq $true)
            {
            
                Write-Host $string successful
            
            }
        else {
                Write-host $string failed
            
            }
}



$soc=Import-Csv -Path C:\test\deepak.csv
$mum=($soc | Where-Object {$_.aggregators -like "MUM"} | Select-Object Hostname).hostname
$nld=($soc | Where-Object {$_.aggregators -like "USA"} | Select-Object Hostname).hostname
$usa=($soc | Where-Object {$_.aggregators -like "NLD"} | Select-Object Hostname).hostname

$result=foreach ($item in $mum) {
    Write-Host Working on $item
    if(Test-Connection -ComputerName $item -Count 1 -Quiet){
        try {
            
            Invoke-Command -ComputerName $item -ScriptBlock {if(!(Test-Path -Path C:\Temp)){New-Item -Path C:\Temp\ -ItemType Directory}}
            robocopy C:\SOC_Aggregator\mum_SOC\ \\$item\c$\temp\ /MIR /Z
            $check1="$?"
            get-Result -result $check1 -string "copy"

            Invoke-Command -ComputerName $item -scriptblock {  Start-Process -FilePath .\C:\Temp\mum.bat -Wait -passthru }
            $install="$?"
            get-Result -result $install -string "Installation"
            
            $hostname=$item
            $status="success"
            $copy=$check1
            $installation=$install
            $issue="none"
        }
        catch {
        $hostname=$item
        $status="failure"
        $copy=if($null -eq $check1){$false}else{$check1}
        $installation=$false
        $issue=$Error[0].exception.message
        }
    }
    else {
        $hostname=$item
        $status="unreachable" # Setting status to false if not reachable
        $issue="Host unreachable"
        $copy="False"
        $installation="False"
    }

    [PSCustomObject]@{
        Hostname = $hostname
        Status = $status
        Error = $issue
        Copy=$copy
        Software=$installation
    }

}

$result | Export-Csv -NoTypeInformation -Path C:\test\results.csv -Append -Force

$result2=foreach ($item in $nld) {
    Write-Host Working on $item
    if(Test-Connection -ComputerName $item -Count 1 -Quiet){
        try {
            
            Invoke-Command -ComputerName $item -ScriptBlock {if(!(Test-Path -Path C:\Temp)){New-Item -Path C:\Temp\ -ItemType Directory}}
            robocopy C:\SOC_Aggregator\nld_SOC\ \\$item\c$\temp\ /MIR /Z
            $check1="$?"
            get-Result -result $check1 -string "copy"

            Invoke-Command -ComputerName $item -scriptblock {  Start-Process -FilePath .\C:\Temp\nld.bat -Wait -passthru }
            $install="$?"
            get-Result -result $install -string "Installation"
            
            $hostname=$item
            $status="success"
            $copy=$check1
            $installation=$install
            $issue="none"
        }
        catch {
        $hostname=$item
        $status="failure"
        $copy=if($null -eq $check1){$false}else{$check1}
        $installation=$false
        $issue=$Error[0].exception.message
        }
    }
    else {
        $hostname=$item
        $status="unreachable" # Setting status to false if not reachable
        $issue="Host unreachable"
        $copy="False"
        $installation="False"
    }

    [PSCustomObject]@{
        Hostname = $hostname
        Status = $status
        Error = $issue
        Copy=$copy
        Software=$installation
    }

}

$result2 | Export-Csv -NoTypeInformation -Path C:\test\results.csv -Append -Force

$result3=foreach ($item in $usa) {
    Write-Host Working on $item
    if(Test-Connection -ComputerName $item -Count 1 -Quiet){
        try {
            
            Invoke-Command -ComputerName $item -ScriptBlock {if(!(Test-Path -Path C:\Temp)){New-Item -Path C:\Temp\ -ItemType Directory | Out-Null}}
            robocopy C:\SOC_Aggregator\usa_SOC\ \\$item\c$\temp\ /MIR /Z
            $check1="$?"
            get-Result -result $check1 -string "copy"

            Invoke-Command -ComputerName $item -scriptblock {  Start-Process -FilePath .\C:\Temp\usa.bat -Wait -passthru }
            $install="$?"
            get-Result -result $install -string "Installation"

            $hostname=$item
            $status="success"
            $copy=$check1
            $installation=$install
            $issue="none"
        }
        catch {
        $hostname=$item
        $status="failure"
        $copy=if($null -eq $check1){$false}else{$check1}
        $installation=$false
        $issue=$Error[0].exception.message
        }
    }
    else {
        $hostname=$item
        $status="unreachable" # Setting status to false if not reachable
        $issue="Host unreachable"
        $copy="False"
        $installation="False"
    }

    [PSCustomObject]@{
        Hostname = $hostname
        Status = $status
        Error = $issue
        Copy=$copy
        Software=$installation
    }

}

$result3 | Export-Csv -NoTypeInformation -Path C:\test\results.csv -Append -Force
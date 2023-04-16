
#variables
$required_modules="HPEoneview.610","Psmenu","PSBanner"
$WarningPreference="Silentlycontinue"
$date=(Get-Date).GetDateTimeFormats()[81]
$ErrorActionPreference="Stop"

# Functions

Function test-iloIP{
    param (
        [parameter(Mandatory=$false)]
        [string]$path

    )
    begin{
        $ErrorActionPreference="Stop"
        $ipv4 = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    }
    process{
        try {
            if($path -notmatch "(\.txt)"){
                throw
            }
            $ilotextfile=Get-Content -Path $path
            if([string]::IsNullOrEmpty($ilotextfile)){
                throw
            }
            for($i=0;$i -lt $ilotextfile.count;$i++){
                if($ilotextfile.count -eq 1){
                    if($ilotextfile -notmatch $ipv4){
                        Write-Output "Line 1, $($ilotextfile) is not a valid IP"
                    }
                }
                else{
                    if($ilotextfile[$i] -notmatch $ipv4){
                        Write-Output "Line $($i+1), $($ilotextfile[$i]) is not a valid IP"
                    }
                }
            }
        }
        catch [System.Management.Automation.ItemNotFoundException]{
            Write-Output "Could not find the file at $path"
        }
        catch {
            if($path -notmatch "(\.txt)"){
                Write-Output "Please enter path for a valid text file."
            }
            elseif([string]::IsNullOrEmpty($ilotextfile)){
                Write-Output "Text file is blank, please select another file"
            }
            else{
                Write-Output $Error[0].exception.message
            }
        }
        finally {
            $Error.Clear()
        }
    }
    end{

    }
}

function test-csv {
    param (
        [parameter(Mandatory)]
        [string]$path
    )
    begin{
        $ipv4 = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
        $script:headers="iloip","username","password"
    }
    process{
        try {
            if($path -notmatch "(\.csv)"){
                throw
            }
            $Script:csv=Import-Csv -Path $path -ErrorAction SilentlyContinue
            $csvheaders=($csv | Get-Member -MemberType NoteProperty).Name
            $script:result=foreach($csvheader in $csvheaders){
                $headers -contains $csvheader
            }

            if($result -contains $false){
                throw
            }
            if([string]::isnullorempty($csv)){
                throw
            }
            For($i=0;$i -lt $csv.Count;$i++){
                if([string]::IsNullOrEmpty($csv[$i].iloip)){
                    Write-Output "Row $($i+2),iloIP is empty"
                }
                else{
                    if($csv[$i].iloIP -notmatch $ipv4){
                        Write-Output "Row $($i+2),iloIP is invalid"
                    }
                }

                if([string]::IsNullOrEmpty($csv[$i].username)){
                    Write-Output "Row $($i+2),username is empty"
                }
                else{
                    if(($csv[$i].username).Length -gt 24){
                        write-Output "Row $($i+2),username exceeds 24 character limit"
                    }
                }

                if([string]::IsNullOrEmpty($csv[$i].Password)){
                    Write-Output "Row $($i+2),Password is empty"
                }
                else{
                    if(($csv[$i].Password).Length -gt 30){
                        write-Output "Row $($i+2),Password exceeds 30 character limit"
                    }
                }
            }
        }
        catch [System.IO.FileNotFoundException]{
            Write-Output "Could not find the file at $path"
        }
        catch {
            if($path -notmatch "(\.csv)"){
                Write-Output "Please enter path for a valid CSV file."
            }
            elseif($result -contains $false){
                Write-Output "Please validate csv headers, they must contain iloIP,username and password columns only."
            }
            elseif([string]::isnullorempty($csv)){
                Write-Output "CSV file is empty, please select another file"
            }
            else{
                Write-Output "Unknown Error happened : $($Error[0].exception.message)"
            }
        }
        finally {
            $Error.Clear()
        }
    }
    end{
    }
}

Function test-iloIPstring{
    param (
        [parameter(Mandatory=$false)]
        [string[]]$IPs

    )
    begin{
        $ipv4 = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    }
    process{
        try {
            for($i=0;$i -lt $IPs.count;$i++){
                if($ips[$i] -notmatch $ipv4){
                    Write-Output "$($ips[$i]) is not a valid IP"
                }
            }
        }
        catch {
            Write-Output $Error[0].exception.message
        }
        finally {
            $Error.Clear()
        }
    }
    end{

    }
}

function set-multiops {
    param(
        [ValidateSet("Text","CSV","Manual")]
        [parameter(Mandatory=$true,HelpMessage='Add help message for user')][string]$Operation,
        [parameter(Mandatory=$false,HelpMessage='Add help message for user')][string]$CSVfilepath,
        [parameter(Mandatory=$false,HelpMessage='Add help message for user')][string]$textfilepath,
        [parameter(Mandatory=$false,HelpMessage='Add help message for user')][string[]]$ManualIPs,
        [parameter(Mandatory=$false,HelpMessage='Add help message for user')][pscredential]$pscredential
    )

    write-host `n
    Write-Host "Enter the operation you want to perfom (multi options available) : "

    $multi_select_options=Show-Menu -MenuItems "Uptime","Addition of servers","Backups","Health check","SPP baseline","SPP Version" -MultiSelect
    if($multi_select_options -contains "Uptime"){
        Write-Host "User has selected : Uptime" -ForegroundColor Cyan
        if($Operation -eq "CSV"){

        }
        elseif ($Operation -eq "text") {
            
        }
        else{

        }
    }   
    if($multi_select_options -contains "Addition of servers"){
        Write-Host "User has selected : Addition of servers" -ForegroundColor Cyan
    }
    if($multi_select_options -contains "Backups"){
        Write-Host "User has selected : Backup" -ForegroundColor Cyan
        if($Operation -eq "text"){
            $IPs=Get-Content -Path $text_path
            $results+=foreach($ip in $IPs){
                try {
                    $connection=Connect-OVMgmt -Hostname $ip -Credential $pscredential -Verbose
                    Write-Host "Connection successfull to $($ip)" -ForegroundColor Yellow
                    Get-OVBackup -ApplianceConnection $connection
                    Disconnect-OVMgmt -Hostname $ip
                }
                catch {
                    Write-Host "Error : $($Error[0].Exception.Message)" -ForegroundColor Red
                }
                finally {
                    <#Do this after the try block regardless of whether an exception occurred or not#>
                }
            }
            $results | Format-Table
        }
        elseif ($Operation -eq "CSV") {
            $csvfile=Import-Csv -Path $csv_path
            $results+=foreach($item in $csvfile){
                try {
                    $SecurePassword=ConvertTo-SecureString -String $item.password -AsPlainText -Force
                    $pscredential = New-Object System.Management.Automation.PSCredential($item.User,$SecurePassword)
                    $connection=Connect-OVMgmt -Hostname $item.IP -Credential $pscredential -Verbose
                    Write-Host "Connection successfull to $($item.ip)" -ForegroundColor Yellow
                    Get-OVBackup -ApplianceConnection $connection
                    Disconnect-OVMgmt -Hostname $ip
                }
                catch {
                    Write-Host "Error : $($Error[0].Exception.Message)" -ForegroundColor Red
                }
                finally {
                    <#Do this after the try block regardless of whether an exception occurred or not#>
                }
            }
            $results | Format-Table
        }
        else{
            $results+=foreach($ip in $manual_ips){
                try {
                    $connection=Connect-OVMgmt -Hostname $ip -Credential $pscredential -Verbose
                    Write-Host "Connection successfull to $($ip)" -ForegroundColor Yellow
                    Get-OVBackup -ApplianceConnection $connection
                    Disconnect-OVMgmt -Hostname $ip
                }
                catch {
                    Write-Host "Error : $($Error[0].Exception.Message)" -ForegroundColor Red
                }
                finally {
                    <#Do this after the try block regardless of whether an exception occurred or not#>
                }
            }
            $results | Export-Csv -Path C:\Users\adm.gdeepak\documents\Backup.csv -Force -notypeinformation
        }
    }
    if($multi_select_options -contains "Health Check"){
        Write-Host "User has selected : Health Check" -ForegroundColor Cyan
    }
    if($multi_select_options -contains "SPP Baseline"){
        Write-Host "User has selected : SPP Baseline" -ForegroundColor Cyan
        if($Operation -eq "text"){
            $IPs=Get-Content -Path $text_path
            $results+=foreach($ip in $IPs){
                try {
                    $connection=Connect-OVMgmt -Hostname $ip -Credential $pscredential -Verbose
                    Write-Host "Connection successfull to $($ip)" -ForegroundColor Yellow
                    $ovbaseline=Get-OVBaseline -ApplianceConnection $connection
                    $name=$ovbaseline.Name
                    $state=$ovbaseline.state
                    $status=$ovbaseline.Status
                    $version=$ovbaseline.version
                    $isofilename=$ovbaseline.isofilename
                    $xmlkeyname=$ovbaseline.isofilename
                    $bundlesize=$ovbaseline.bundlesize
                    $locations=$ovbaseline.locations
                    $Issue="No Error"
                    Disconnect-OVMgmt -Hostname $ip
                }
                catch {
                    $name="NA"
                    $state="NA"
                    $status="NA"
                    $version="NA"
                    $isofilename="NA"
                    $xmlkeyname="NA"
                    $bundlesize="NA"
                    $locations="NA"
                    $Issue=$($Error[0].Exception.Message)
                }
                finally {
                    <#Do this after the try block regardless of whether an exception occurred or not#>
                }
                [PSCustomObject]@{
                    hostname=$ip
                    Name = $name
                    State=$state
                    Status=$status
                    Version=$version
                    IsoFileName=$isofilename
                    XMLKeyName=$xmlkeyname
                    BundleSize=$bundlesize
                    Locations=$locations
                    Issue=$Issue
                }
            }
            $results | Export-Csv -Path C:\Users\adm.gdeepak\documents\spp_baseline.csv -Force -notypeinformation
        }
        elseif ($Operation -eq "CSV") {
            $csvfile=Import-Csv -Path $csv_path
            $results+=foreach($item in $csvfile){
                try {
                    $SecurePassword=ConvertTo-SecureString -String $item.password -AsPlainText -Force
                    $pscredential = New-Object System.Management.Automation.PSCredential($item.User,$SecurePassword)
                    $connection=Connect-OVMgmt -Hostname $item.IP -Credential $pscredential -Verbose
                    Write-Host "Connection successfull to $($item.ip)" -ForegroundColor Yellow
                    $ovbaseline=Get-OVBaseline -ApplianceConnection $connection
                    $name=$ovbaseline.Name
                    $state=$ovbaseline.state
                    $status=$ovbaseline.Status
                    $version=$ovbaseline.version
                    $isofilename=$ovbaseline.isofilename
                    $xmlkeyname=$ovbaseline.isofilename
                    $bundlesize=$ovbaseline.bundlesize
                    $locations=$ovbaseline.locations
                    $Issue="No Error"
                    Disconnect-OVMgmt -Hostname $ip
                }
                catch {
                    $name="NA"
                    $state="NA"
                    $status="NA"
                    $version="NA"
                    $isofilename="NA"
                    $xmlkeyname="NA"
                    $bundlesize="NA"
                    $locations="NA"
                    $Issue=$($Error[0].Exception.Message)
                }
                finally {
                    <#Do this after the try block regardless of whether an exception occurred or not#>
                }
                [PSCustomObject]@{
                    hostname=$item.IP
                    Name = $name
                    State=$state
                    Status=$status
                    Version=$version
                    IsoFileName=$isofilename
                    XMLKeyName=$xmlkeyname
                    BundleSize=$bundlesize
                    Locations=$locations
                    Issue=$Issue
                }
            }
            $results | Format-Table
        }
        else{
            $results+=foreach($ip in $manual_ips){
                try {
                    $connection=Connect-OVMgmt -Hostname $ip -Credential $pscredential -Verbose
                    Write-Host "Connection successfull to $($ip)" -ForegroundColor Yellow
                    $ovbaseline=Get-OVBaseline -ApplianceConnection $connection
                    $name=$ovbaseline.Name
                    $state=$ovbaseline.state
                    $status=$ovbaseline.Status
                    $version=$ovbaseline.version
                    $isofilename=$ovbaseline.isofilename
                    $xmlkeyname=$ovbaseline.isofilename
                    $bundlesize=$ovbaseline.bundlesize
                    $locations=$ovbaseline.locations
                    $Issue="No Error"
                    Disconnect-OVMgmt -Hostname $ip
                }
                catch {
                    $name="NA"
                    $state="NA"
                    $status="NA"
                    $version="NA"
                    $isofilename="NA"
                    $xmlkeyname="NA"
                    $bundlesize="NA"
                    $locations="NA"
                    $Issue=$($Error[0].Exception.Message)
                }
                finally {
                    <#Do this after the try block regardless of whether an exception occurred or not#>
                }
                [PSCustomObject]@{
                    hostname=$ip
                    Name = $name
                    State=$state
                    Status=$status
                    Version=$version
                    IsoFileName=$isofilename
                    XMLKeyName=$xmlkeyname
                    BundleSize=$bundlesize
                    Locations=$locations
                    Issue=$Issue
                }
            }
            $results | Format-Table
        }
    }
    if($multi_select_options -contains "SPP version"){
        Write-Host "User has selected : SPP Version" -ForegroundColor Cyan
    }
}


# Main

#Implementing Nuget provider
if(!(Get-PackageProvider -ListAvailable | Where-Object{$_.name -eq "nuget"})){
    Write-host "[ $($date) ] Copying Nuget package provider form $($PSScriptRoot) to "C:\Program Files\PackageManagement\ProviderAssemblies\"" `
    -ForegroundColor Yellow
    Get-ChildItem -Path $PSScriptRoot | Where-Object {$_.name -eq "Nuget" -and $_.psiscontainer -eq $true} | `
    Copy-Item -Destination "C:\Program Files\PackageManagement\ProviderAssemblies" -Force -Recurse
    Write-host "[ $($date) ] Importing Nuget package provider" -ForegroundColor Yellow
    Import-PackageProvider nuget | Out-Null
    Write-host "[ $($date) ] Sucessfully imported nuget package provider" -ForegroundColor Yellow
}

# Copy pasting required module in module path
foreach($path in $env:PSModulePath.Split(";") | Where-Object {$_ -notlike "C:\program files\windowsapps\*"}){
    foreach($required_module in $required_modules){
        Write-host "[ $($date) ] Importing $($required_module) in powershell current session" -ForegroundColor Yellow
        Import-Module $required_module -ErrorAction SilentlyContinue
        if(!$?){
            Write-host "[ $($date) ] $($required_module) not found, copying it from $($PSScriptRoot) to $($path)" -ForegroundColor Yellow
            Get-ChildItem -Path $PSScriptRoot | Where-Object {$_.name -eq $required_module -and $_.psiscontainer -eq $true} | `
            Copy-Item -Destination $path -Recurse -Force
            Write-Host "[ $($date) ] Successfully copied $($required_module) from $PSScriptRoot to $($path)" -ForegroundColor Yellow
        }
    }
}

Write-Banner -FontSize 10 "Auto OneView"
Write-Host '---------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host '                   Welcome to Oneview Automation                           ' -ForegroundColor Cyan
Write-Host '---------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host `n
Import-Module PSMenu
Write-Output "Please select one of the option to continue"
$main_selected_option=Show-Menu @("Text file","CSV file","Manual IPs",$(Get-MenuSeparator),"Quit")
switch ($main_selected_option) {
    "Text file" {
        Write-Host `n
        $text_path=Read-Host "Enter the path of Text file"
        Write-Host "Text file path is $($text_path)" -ForegroundColor Cyan
        try{
            if((test-iloIP -path $text_path)){
                throw
            }
            else{
                Write-Host "Text file successfully validated" -ForegroundColor Yellow
                $User=Read-Host "Enter username"
                $password=Read-Host "Enter Password" -AsSecureString
                $pscredential = New-Object System.Management.Automation.PSCredential($User,$password)
                set-multiops -Operation Text -pscredential $pscredential -textfilepath $text_path
            }
        }
        catch{
            $validation_messages=test-iloIP -path $text_path
            foreach($validation_message in $validation_messages){   
                Write-host "Error : $($validation_message)" -ForegroundColor Red
            }
            return
        }
    }
    "CSV file" {    
        Write-Host `n
        $csv_path=Read-Host "Enter the path of CSV file"
        Write-Host "CSV file path is $($csv_path)" -ForegroundColor Cyan
        set-multiops -Operation CSV -CSVfilepath $csv_path
    }
    "Manual IPs"{
        Write-Host `n
        $manual_ips_ns=Read-Host "Enter Manual IPs separated by comma"
        Write-Host "Entered manual IPs are $($manual_ips)" -ForegroundColor Cyan
        $manual_ips=$manual_ips_ns.Split(',')
        $User=Read-Host "Enter username"
        $password=Read-Host "Enter Password" -AsSecureString
        $pscredential = New-Object System.Management.Automation.PSCredential($User,$password)
        set-multiops -Operation Manual -pscredential $credential -ManualIPs $manual_ips
    }
    "Quit" {
        Write-Host `n
        Write-Host "User has quit the operation" -ForegroundColor Red
        return
    }
}
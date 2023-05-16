
<#
    BlankLine
    Document
    DocumentOption
    Export-Document
    Footer
    Header
    Image
    LineBreak
    PageBreak
    Paragraph
    Section
    Set-Style
    Style
    Table
    TableStyle
    Text
    TOC
    Write-PScriboMessage
#>

#variables
$required_modules="Psmenu","PSBanner","pscribo","pscribocharts"
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

function get-asbuilt {
    [CmdletBinding()]
    param (
        [ValidateSet("Text","CSV","Manual")]
        [parameter(Mandatory=$false,HelpMessage='Add help message for user')][string]$Operation,
        [parameter(Mandatory=$false,HelpMessage='Add help message for user')][string]$CSVfilepath,
        [parameter(Mandatory=$false,HelpMessage='Add help message for user')][string]$textfilepath,
        [parameter(Mandatory=$false,HelpMessage='Add help message for user')][string[]]$ManualIPs,
        [parameter(Mandatory=$true,HelpMessage='Add help message for user')][pscredential]$pscredential
    )
    
    begin {
        Write-Host "Please wait while we verify the connection to the target host" -ForegroundColor Yellow
        $connection=Connect-OVMgmt -Appliance $manual_ip -Credential $pscredential
        Write-Host "Connection to $($manual_ip) is successfull..." -ForegroundColor Yellow
    }
    
    process {
        # Section Uses PS Scribo to Turn table in to HTML, TXT, DOC
        $document = Document 'ReportDoc' -Verbose {
	        TOC
	        pagebreak
            Paragraph -Style Heading1 'Summary of OneView '
            LineBreak
            BlankLine

            # Section 1
            Paragraph -Style Heading3 '1. Address Pool Information'
	        blankline
            Section -Style Heading2 "1.1 Address Pool details" {
                $addressPools = Get-OVAddressPool -applianceconnection $connection | Select-Object @{Name='Name';Expression={$_.name}}, 
                @{Name='Type';Expression={$_.poolType}}, @{Name='Enabled';Expression={$_.enabled}}, 
                @{Name='Count';Expression={$_.totalCount}}, @{Name='Allocated';Expression={$_.allocatedCount}}, 
                @{Name='Available';Expression={$_.freeCount}}
                Table -Name 'OVAddressPool' -InputObject $addressPools -Columns "Name","Type","Enabled","Count","Allocated","Available" `
                -ColumnWidths 20,20,20,20,20,20 -Headers "Name","Type","Enabled","Count","Allocated","Available" -Caption "OVAddressPool"
            }

            Section -Style Heading2 "1.2 Address Pool Range details"{
                $addressPoolRanges_allproperty = Get-OVAddressPoolRange -applianceconnection $connection | Select-Object *

                $addressPoolRanges=$addressPoolRanges_allproperty | select-object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Name';Expression={$_.Name}}, @{Name='Enabled';Expression={$_.Enabled}}, @{Name='Category';Expression={$_.rangeCategory}}, `
                @{Name='Total';Expression={$_.Totalcount}}, @{Name='Allocated';Expression={$_.Allocatedidcount}}, `
                @{Name='Available';Expression={$_.freeidcount}},@{Name='Reserved';Expression={$_.Reservedidcount}}, `
                @{Name='Start';Expression={$_.Startaddress}}, @{Name='End';Expression={$_.Endaddress}}

                Table -Name 'OVAddressPoolRange' -InputObject $addressPoolRanges -Columns "Appliance","Name","Enabled","Category","Total",`
                "Allocated","Available","Reserved","Start","End" -ColumnWidths 15,20,15,15,15,15,15,15,25,25 `
                -Headers "Appliance","Name","Enabled","Category","Total","Allocated","Available","Reserved","Start","End" -Caption "OVAddressPoolRange"
            }
    
            Section -Style Heading2 "1.3 Address Pool Subnet details" {
                $addressPoolSubnets_allproperty = Get-OVAddressPoolSubnet -applianceconnection $connection | Select-Object * 
                $addressPoolSubnets= $addressPoolSubnets_allproperty | select-object @{Name='Appliance';Expression={$_.ApplianceConnection}}, `
                @{Name='Network ID';Expression={$_.NetworkID}}, @{Name='Subnet Masks';Expression={$_.Subnetmask}}, `
                @{Name='Gateway';Expression={$_.Gateway}},@{Name='DNS Servers';Expression={$_.DNSServers -join ","}}

                Table -Name 'OVAddressPoolSubnet' -InputObject $addressPoolSubnets -Columns "Appliance","Network ID","Subnet Masks",`
                "Gateway","DNS Servers" -ColumnWidths 20,20,20,20,40 -Headers "Appliance","Network ID","Subnet Masks","Gateway","DNS Servers"`
                -Caption "OVAddressPoolSubnet"
            }

            # Section 2
            BlankLine
            Paragraph -Style Heading3 '2. OneView critical Alerts'
            BlankLine
            Section -Style Heading2 "2.1 Top 20 Critical OneView alerts"{
                $critovalerts= Get-OVAlert -ApplianceConnection $connection | select-object * | Where-Object {$_.severity -eq "critical"} | `
                Select-Object -First 20 
                $ovalerts=$critovalerts | select-object @{Name='Severity';Expression={$_.severity}},`
                @{Name='Resource';Expression={$_.associatedresource.resourcename}},`
                @{Name='Created';Expression={$_.Created}},@{Name='Modified';Expression={$_.Modified}},@{Name='State';Expression={$_.alertstate}},`
                @{Name='Description';Expression={$_.Description}}
        
                Table -Name 'Critical OVAlerts' -InputObject $ovalerts -Columns "Severity","Resource","Created","Modified","State","Description" `
                -ColumnWidths 20,20,20,20,20,40 -Headers "Severity","Resource","Created","Modified","State","Description" -Caption 'Critical OVAlerts'
            }

            # Section 3
            BlankLine
            Paragraph -Style Heading3 '3. Appliance Information'
            BlankLine
            Section -Style Heading2 "3.1 Audit log Forwarding "{
                $auditlog_forwarding_allproperty= Get-OVApplianceAuditLogForwarding -applianceconnection $connection | Select-Object *
                $auditlog_forwarding= $auditlog_forwarding_allproperty | Select-Object @{Name='Enabled';Expression={$_.Enabled}},`
                @{Name='Destinations';Expression={$_.Destinations -join ','}},@{Name='appliance';Expression={$_.ApplianceConnection}}
                Table -Name 'Auditlog forwarding' -InputObject $auditlog_forwarding -Columns "Appliance","Destinations","Enabled" -ColumnWidths `
                "20","50","20" -Headers "Appliance","Destinations","Enabled" -Caption 'Auditlog forwarding'
            }

            Section -Style Heading2 "3.2 Available security mode"{
                $available_securitymode_allproperty= Get-OVApplianceAvailableSecurityMode -applianceconnection $connection | Select-Object *
                $available_securitymode= $available_securitymode_allproperty | Select-Object @{Name='Mode Name';Expression={$_.modename}},`
                @{Name='Current Mode';Expression={$_.currentmode}},@{Name='appliance';Expression={$_.ApplianceConnection}}
                Table -Name 'Available Security Mode' -InputObject $available_securitymode -Columns "Appliance","Mode Name","Current Mode" `
                -ColumnWidths "30","30","30" -Headers "Appliance","Mode Name","Current Mode" -Caption 'Available Security Mode'
            }

            Section -Style Heading2 "3.3 Certificate status"{
                $certificate_status_allproperty=Get-OVApplianceCertificateStatus -applianceconnection $connection | Select-Object *
                $certificate_status=$certificate_status_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='CN';Expression={$_.commonname}},@{Name='Issuer';Expression={$_.Issuer}},@{Name='Valid from';Expression={$_.validfrom}}`
                ,@{Name='Valid Until';Expression={$_.validuntil}},@{Name='Expires in days';Expression={$_.Expiresindays}}
                Table -Name 'Certificate Status' -InputObject $certificate_status -Columns "Appliance","CN","Issuer","Valid from","Valid until",`
                "Expires in days" -ColumnWidths 20,20,20,20,20,20 -Headers "Appliance","CN","Issuer","Valid from","Valid until","Expires in days"`
                -Caption 'Certificate status'
            }

            Section -Style Heading2 "3.4 Current Security Mode"{
                $security_mode_allproperty=Get-OVApplianceCurrentSecurityMode -applianceconnection $connection | Select-Object *
                $security_mode=$security_mode_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Current Mode';Expression={$_.currentmode}},@{Name='Mode Name';Expression={$_.modename}}    
                Table -Name 'CurrentSecurityMode' -InputObject $security_mode -Columns "Appliance","Current Mode","Mode name" `
                -ColumnWidths "33","33","33" -Headers "Appliance","Current Mode","Mode name" -Caption "Current security mode"
            }

            Section -Style Heading2 "3.5 Datetime"{
                $datetime_allproperty=Get-OVApplianceDateTime -applianceconnection $connection | Select-Object *
                $datetime=$datetime_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Locale';Expression={$_.locale}},@{Name='Timezone';Expression={$_.Timezone}},@{Name='Datetime';Expression={$_.datetime}},`
                @{Name='NTP Servers';Expression={$_.Ntpservers -join ","}},@{Name='Sync with Host';Expression={$_.syncwithhost}},`
                @{Name='Locale Display Name';Expression={$_.localedisplayname}}
                Table -Name 'datetime' -InputObject $datetime -Columns "Appliance","locale","Timezone","datetime","NTP servers","Sync with host",`
                "locale display name" -ColumnWidths "14","14","14","14","14","14","14" -Headers "Appliance","locale","Time Zone","datetime",`
                "NTP servers","Sync with host","locale display name" -Caption "Date time"
            }

            Section -Style Heading2 "3.6 Global settings"{
                $global_settings_allproperty=Get-OVApplianceGlobalSetting -ApplianceConnection $connection | Select-Object *
                $global_settings= $global_settings_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Name';Expression={$_.Name}},@{Name='Value';Expression={$_.Value}},@{Name='Created';Expression={$_.created}},`
                @{Name='Modified';Expression={$_.Modified}},@{Name='Group';Expression={$_.Group}}
                Table -Name 'GlobalSettings' -InputObject $global_settings -Columns "Appliance","Name","Value","Created","Modified","Group"`
                -ColumnWidths "16","16","16","16","16" -Headers "Appliance","Name","Value","Created","Modified","Group" -Caption "Global Settings"
            }

            Section -Style Heading2 "3.7 IPv4 details"{
                $ipdetails_allproperty=Get-OVApplianceIPAddress -applianceconnection $connection | Select-Object *
                $ipdetails =$ipdetails_allproperty | Select-Object `
                @{Name='Hostname';Expression={$_.hostname}},@{Name='IPv4 Address';Expression={$_.IPv4Address}},`
                @{Name='IPv4 SM';Expression={$_.IPv4SubnetMask}},`
                @{Name='IPv4 gateway';Expression={$_.IPv4Gateway}},@{Name='IPv4 Type';Expression={$_.IPv4Type}},`
                @{Name='IPv4 DNS Servers';Expression={$_.IPv4DnsServers -join ','}}
                Table -Name 'IPdetails' -InputObject $ipdetails -Columns "Hostname","IPv4 Address","IPv4 SM","IPv4 gateway","IPv4 Type",`
                "IPv4 Dns Servers" -ColumnWidths "16","16","16","16","16","16" -Headers "Hostname","IPv4 Address","IPv4 SM","IPv4 gateway",`
                "IPv4 Type","IPv4 DNS Servers" -Caption "IPv4 Details"
            }

            Section -Style Heading2 "3.8 Network configuration"{
                $network_config_allproperty=(Get-OVApplianceNetworkConfig -applianceconnection $connection).appliancenetworks | Select-Object *
                $network_config=$network_config_allproperty | Select-Object @{Name='Network Label';Expression={$_.networklabel}},`
                @{Name='Interface Name';Expression={$_.interfacename}},@{Name='Device';Expression={$_.device}},`
                @{Name='MacAddress';Expression={$_.MacAddress}},@{Name='Ipv4type';Expression={$_.Ipv4type}},@{Name='Ipv6Type';Expression={$_.Ipv6Type}},`
                @{Name='Active Node';Expression={$_.activenode}}
                Table -Name 'Network Configuration' -InputObject $network_config -Columns "Network label","Interface Name","Device",`
                "MacAddress","Ipv4Type","IPv6Type","Active Node" -ColumnWidths "14","14","14","14","14","14","14" -Headers "Network label",`
                "Interface Name","Device","MacAddress","Ipv4Type","IPv6Type","Active Node" -Caption "Network Configuration"
            }

            Section -Style Heading2 "3.9 Appliance Proxy"{
                $appliance_proxy_allproperty=Get-OVApplianceProxy -applianceconnection $connection | Select-Object *
                $appliance_proxy=$appliance_proxy_allproperty | select-object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Protocol';Expression={$_.Protocol}},@{Name='Port';Expression={$_.Port}}
                Table -Name 'Appliance Proxy' -InputObject $appliance_proxy -Columns "Appliance","Protocol","Port" -ColumnWidths "30","30","30"`
                -Headers "Appliance","Protocol","Port" -Caption "Appliance Proxy"
            }

            Section -Style Heading2 "3.10 Security Protocol"{
                $security_protocol_allproperty=Get-OVApplianceSecurityProtocol -applianceconnection $connection | Select-Object *
                $security_protocol=$security_protocol_allproperty | Select-Object @{Name='Name';Expression={$_.name}},`
                @{Name='CipherSuites';Expression={$_.CipherSuites}},@{Name='Category';Expression={$_.Category}},@{Name='Mode';Expression={$_.mode}},`
                @{Name='ModeisEnabled';Expression={$_.ModeisEnabled}},@{Name='Enabled';Expression={$_.enabled}}
                Table -Name 'Security Protocol' -InputObject $security_protocol -Columns "Name","CipherSuites","Category","Mode",`
                "ModeisEnabled","Enabled" -ColumnWidths "16","16","16","16","16","16" -Headers "Name","CipherSuites","Category","Mode",`
                "ModeisEnabled","Enabled" -Caption "Security Protocols"
            }

            Section -Style Heading2 "3.11 Service Console Access"{
                $service_access_allproperty=Get-OVApplianceServiceConsoleAccess -applianceconnection $connection | Select-Object *
                $service_access=$service_access_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Enabled';Expression={$_.Enabled}}
                Table -Name 'ServiceConsoleAccess' -InputObject $service_access -Columns "Appliance","Enabled" -ColumnWidths "50","50" `
                -Headers "Appliance","Enabled" -Caption "Service Console Access"
            }

            Section -Style Heading2 "3.12 SNMP EngineID"{
                $snmp_engine_allproperty=Get-OVApplianceSnmpV3EngineId -applianceconnection $connection | Select-Object *
                $snmp_engine=$snmp_engine_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='EngineID';Expression={$_.EngineID}}
                Table -Name 'SNMPEngineID' -InputObject $snmp_engine -Columns "Appliance","EngineID" -ColumnWidths "50","50" `
                -Headers "Appliance","EngineID" -Caption "SNMP EngineID"
            }

            Section -Style Heading2 "3.13 SSH Access"{
                $ssh_access=Get-OVApplianceSshAccess -applianceconnection $connection | Select-Object `
                @{Name='Appliance';Expression={$_.ApplianceConnection}},@{Name='Enabled';Expression={$_.Enabled}}
                Table -Name 'SSH Access' -InputObject $ssh_access -Columns "Appliance","Enabled" -ColumnWidths "50","50" `
                -Headers "Appliance","Enabled" -Caption "SSH Access"
            }

            Section -Style Heading2 "3.14 Certificate status"{
                $certificate_status=Get-OVApplianceTrustedCertificate -applianceconnection $connection | Select-Object `
                @{Name='Name';Expression={$_.name}},@{Name='Alias';Expression={$_.AliasName}},@{Name='Certificate';Expression={$_.certificate}},`
                @{Name='Status';Expression={$_.CertificateStatus}},@{Name='Created';Expression={$_.created}},`
                @{Name='Modified';Expression={$_.Modified}}
                Table -Name 'Certificate Status' -InputObject $certificate_status -Columns "Name","Alias","Certificate","Status",`
                "Created","Modified" -ColumnWidths "16","16","16","16","16","16" -Headers "Name","Alias","Certificate","Status",`
                "Created","Modified" -Caption "Certificate Status"
            }

            Section -Style Heading2 "3.15 Two Factor Authentication"{
                $twofactor_auth=Get-OVApplianceTwoFactorAuthentication -applianceconnection $connection | Select-Object `
                @{Name='Appliance';Expression={$_.ApplianceConnection}},@{Name='Enabled';Expression={$_.enabled}},`
                @{Name='StrictEnforcement';Expression={$_.StrictEnforcement}},@{Name='AllowLocalLogin';Expression={$_.AllowLocalLogin}},`
                @{Name='AllowEmergencyLogin';Expression={$_.AllowEmergencyLogin}},@{Name='EmergencyLoginType';Expression={$_.EmergencyLoginType}}
                Table -Name 'Two Factor Authentication' -InputObject $twofactor_auth -Columns "Appliance","Enabled","StrictEnforcement",`
                "AllowLocalLogin","AllowEmergencyLogin","EmergencyLoginType" -ColumnWidths "16","16","16","16","16","16" `
                -Headers "Appliance","Enabled","StrictEnforcement","AllowLocalLogin","AllowEmergencyLogin","EmergencyLoginType" `
                -Caption "Two Factor Authentication"
            }

            # Section 4
            BlankLine
            Paragraph -Style Heading3 '4. Backup Information'
            BlankLine

            Section -Style Heading2 "4.1 Automatic Backup Config"{
                $automatic_backup_allproperty=Get-OVAutomaticBackupConfig -applianceconnection $connection | Select-Object *
                $automatic_backup=$automatic_backup_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Enabled';Expression={$_.enabled}},@{Name='Protocol';Expression={$_.Protocol}},@{Name='Interval';Expression={$_.scheduleinterval}},`
                @{Name='Days';Expression={$_.scheduledays}},@{Name='Time';Expression={$_.scheduletime}},`
                @{Name='Directory';Expression={$_.remoteserverdir}}
                Table -Name 'Automatic Backup' -InputObject $automatic_backup -Columns "Appliance","Enabled","Protocol","Directory","Interval",`
                "Days","time" -ColumnWidths "14","14","14","14","14","14","14" -Headers "Appliance","Enabled","Protocol","Directory",`
                "Interval","Days","time" -Caption "Automatic Backup config"
            }

            Section -Style Heading2 "4.2 Backup Information"{
                try {
                    $backup_info=Get-OVBackup -applianceconnection $connection | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                    @{Name='Created';Expression={$_.created}},@{Name='Modified';Expression={$_.Modified}},@{Name='Percent';Expression={$_.percentcomplete}},`
                    @{Name='Status';Expression={$_.status}},@{Name='Type';Expression={$_.Backuptype}}
                    Table -Name 'Backup Information' -InputObject $backup_info -Columns "Appliance","Created","Modified","Percent","Status",`
                    "Type" -ColumnWidths "16","16","16","16","16" -Headers "Appliance","Created","Modified","Percent","Status",`
                    "Type" -Caption "Backup Information"   
                }
                catch {
                    Paragraph "There is no backup information available." -Bold
                    Write-PScriboMessage -Message "There is no backup information available."
                }
            }

            # Section 5
            BlankLine
            Paragraph -Style Heading3 '5. Baseline Information'
            BlankLine

            Section -Style Heading2 "5.1 Baseline "{
                $baseline_allproperty=Get-OVBaseline -applianceconnection $connection | Select-Object *
                $baseline=$baseline_allproperty | Select-Object @{Name='Name';Expression={$_.name}},@{Name='State';Expression={$_.state}},`
                @{Name='Status';Expression={$_.status}},@{Name='Version';Expression={$_.version}},@{Name='IsoFileName';Expression={$_.isofilename}}
                Table -Name 'Baseline' -InputObject $baseline -Columns "Name","State","Status","Version","Isofilename" `
                -ColumnWidths "15","15","15","15","40" -Headers "Name","State","Status","Version","Isofilename" -Caption "Baseline"
            }

            Section -Style Heading2 "5.2 Baseline Repository"{
                $baselinerepo_allproperty=Get-OVBaselineRepository -applianceconnection $connection | Select-Object *
                $baselinerepo=$baselinerepo_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Name';Expression={$_.name}},@{Name='Type';Expression={$_.type}},@{Name='Status';Expression={$_.status}},`
                @{Name='Free';Expression={$_.availablespace}},@{Name='Total';Expression={$_.totalspace}}
                Table -Name 'Baseline Repository' -InputObject $baselinerepo -Columns "Appliance","name","Type","Status","Free","Total" `
                -ColumnWidths "16","16","16","16","16" -Headers "Appliance","name","Type","Status","Free","Total" -Caption "Baseline Repository"
            }

            # Section 6
            BlankLine
            Paragraph -Style Heading3 '6. Cluster Information'
            BlankLine

            Section -Style Heading2 "6.1 Cluster Manager"{
                Write-PScriboMessage -Message "There is no cluster information available."
                Paragraph "There is no cluster information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "6.2 Cluster Node"{
                Write-PScriboMessage -Message "There is no cluster node information available."
                Paragraph "There is no cluster node information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "6.3 Cluster Profile"{
                Write-PScriboMessage -Message "There is no cluster profile information available."
                Paragraph "There is no cluster profile information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 7
            BlankLine
            Paragraph -Style Heading3 '7. Composer Information'
            BlankLine

            Section -Style Heading2 "7.1 Composer ILO Status"{
                Write-PScriboMessage -Message "There are no composer Ilo status information available."
                Paragraph "There are no composer Ilo status information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "7.2 Composer node"{
                Write-PScriboMessage -Message "There are no composer node information available."
                Paragraph "There are no composer node information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 8
            BlankLine
            Paragraph -Style Heading3 '8. DataCenter Information'
            BlankLine

            Section -Style Heading2 "8.1 Datacenter"{
                $datacenter=Get-OVDataCenter -ApplianceConnection $connection | Select-Object @{Name='Name';Expression={$_.name}},`
                @{Name='State';Expression={$_.state}},@{Name='Status';Expression={$_.status}},`
                @{Name='Primary Contact';Expression={$_.remotesupportlocation.primarycontact.email}},`
                @{Name='Address';Expression={$_.remotesupportlocation.Streetaddress1+","+$_.remotesupportlocation.Streetaddress2+","`
                +$_.remotesupportlocation.city+","+$_.remotesupportlocation.provincestate+","+$_.remotesupportlocation.Postalcode`
                +$_.remotesupportlocation.Countrycode}},@{Name='timezone';Expression={$_.remotesupportlocation.timezone}}
                Table -Name 'Datacenter' -InputObject $datacenter -Columns "Name","State","Status","Primary contact","Address","Timezone" `
                -ColumnWidths "16","16","16","16","16","16" -Headers "Name","State","Status","Primary contact","Address","Timezone" -Caption "Datacenter"
            }

            # Section 9
            BlankLine
            Paragraph -Style Heading3 '9. Drive Information'
            BlankLine

            Section -Style Heading2 "9.1 Drive Enclosure Information"{
                Write-PScriboMessage -Message "There is no drive enclosure information available."
                Paragraph "There is no drive enclosure information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "9.2 Enclosue group information"{
                Write-PScriboMessage -Message "There is no enclosure group information available."
                Paragraph "There is no enclosure group information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 10
            BlankLine
            Paragraph -Style Heading3 '10. Eula Status'
            BlankLine

            Section -Style Heading2 "10.1 Eula Status"{
                $eula=Get-OVEulaStatus -Appliance $connection | Select-Object @{Name='Appliance';Expression={$_.appliance}},`
                @{Name='Accepted';Expression={$_.Accepted}}

                Table -Name 'Eula Status' -InputObject $eula -Columns "Appliance","Accepted" -ColumnWidths "50","50" -Headers "Appliance","Accepted" `
                -Caption "Eula Staus"
            }

            # Section 11
            BlankLine
            Paragraph -Style Heading3 '11. Fabric information'
            BlankLine

            Section -Style Heading2 "11.1 Fabric Manager"{
                Write-PScriboMessage -Message "There is no fabric manager information available."
                Paragraph "There is no fabric manager information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 12
            BlankLine
            Paragraph -Style Heading3 '12. Health Status Information'
            BlankLine

            Section -Style Heading2 "12.1 Health status"{
                $health_allproperty=Get-OVHealthStatus -ApplianceConnection $connection | Select-Object *
                $health=$health_allproperty | Select-Object @{Name='Resource';Expression={$_.resourcetype}},@{Name='Available';Expression={$_.available}},`
                @{Name='Capacity';Expression={$_.Capacity}},@{Name='Status';Expression={$_.statusmessage}}
                Table -Name 'Health Status' -InputObject $health -Columns "Resource","Available","Capacity","Status" -ColumnWidths "20","20","20","40"`
                -Headers "Resource","Available","Capacity","Status" -Caption "Health Status"
            }

            # Section 13
            BlankLine
            Paragraph -Style Heading3 '13. Server Information'
            BlankLine

            Section -Style Heading2 "13.1 Device details"{
                $device_details_allproperty=get-ovserver -ApplianceConnection $connection | Select-Object *
                $device_details=$device_details_allproperty | Select-Object @{Name='Name';Expression={$_.name}},`
                @{Name='Servername';Expression={$_.Servername}},@{Name='State';Expression={$_.status}},@{Name='Power';Expression={$_.powerstate}},`
                @{Name='Serial Number';Expression={$_.serialNumber}},@{Name='Model';Expression={$_.model}},@{Name='ROM';Expression={$_.romversion}},`
                @{Name='iLO';Expression={$_.mpmodel}},@{Name='iLO Version';Expression={$_.mpFirmwareVersion}},`
                @{Name='license';Expression={$_.licensingintent}}
                Table -Name 'Server details' -InputObject $device_details -Columns "Name","Servername","State","Power","Serial Number","Model",`
                "ROM","iLO","iLO Version","License" -ColumnWidths "10","10","10","10","10","10","10","10","10","10" -Headers "Name","Servername",`
                "State","Power","Serial Number","Model","ROM","iLO","iLO Version","License" -Caption "Device Details"
            }

            Section -Style Heading2 "13.2 Server Hardware type"{
                $server_hardware_allproperty=Get-OVServerHardwareType -ApplianceConnection $connection | Select-Object *
                $server_hardware=$server_hardware_allproperty | Select-Object @{Name='Name';Expression={$_.name}},`
                @{Name='type';Expression={$_.type}},@{Name='Created';Expression={$_.created}},@{Name='Modified';Expression={$_.modified}},`
                @{Name='Form factor';Expression={$_.formfactor}},@{Name='Adaptors';Expression={$_.Adaptors -join ","}}
                Table -Name 'Hardware type' -InputObject $server_hardware -Columns "Name","Type","Created","Modified","Form factor",`
                "Adaptors" -ColumnWidths "16","16","16","16","16","16" -Headers "Name","Type","Created","Modified","Form factor",`
                "Adaptors" -Caption "Hardware Types"
            }

            Section -Style Heading2 "13.3 NTP Configuration"{
                $ntp_allproperty=Get-OVServerNTPConfiguration -ApplianceConnection $connection | select-object *
                $ntp=$ntp_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Name';Expression={$_.Name}},@{Name='Created';Expression={$_.created}},@{Name='Modified';Expression={$_.modified}},`
                @{Name='Value';Expression={$_.value}}
                Table -Name 'NTP Configuration' -InputObject $ntp -Columns "Appliance","Name","Created","Modified","Value" `
                -ColumnWidths "20","20","20","20","20" -Headers "Appliance","Name","Created","Modified","Value" -Caption "NTP Configuration"
            }

            Section -Style Heading2 "13.4 Server Profile"{
                Write-PScriboMessage -Message "There is no server profile information available."
                Paragraph "There is no server profile information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "13.5 Server Profile Conncetion list"{
                Write-PScriboMessage -Message "There is no server profile connection list information available."
                Paragraph "There is no server profile connection list information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "13.6 Server Profile template"{
                Write-PScriboMessage -Message "There is no server profile template information available." 
                Paragraph "There is no server profile template information available" -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 14
            BlankLine
            Paragraph -Style Heading3 '14. Remote Information'
            BlankLine

            Section -Style Heading2 "14.1 Remote Support"{
                try {
                    $remote_support_allproperty=Get-OVRemoteSupport -ApplianceConnection $connection | Select-Object *
                    $remote_support=$remote_support_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                    @{Name='Registered';Expression={$_.Registered}},@{Name='Enabled';Expression={$_.enabled}},@{Name='Connected';Expression={$_.connected}},`
                    @{Name='Company';Expression={$_.companyname}},@{Name='Created';Expression={$_.created}},@{Name='Modified';Expression={$_.modified}}
                    Table -Name 'Remote Support' -InputObject $remote_support -Columns "Appliance","Registered","Enabled","Connected","Company",`
                    "Created","Modified" -ColumnWidths "16","16","16","16","16","16" -Headers "Appliance","Registered","Enabled","Connected","Company",`
                    "Created","Modified" -Caption "Remote Support"   
                }
                catch {
                    Write-PScriboMessage -Message "There is no remote support information available." 
                    Paragraph "There is no remote support information available" -Bold
                }
            }

            Section -Style Heading2 "14.2 Remote Support Contact"{
                try {
                    $rs_contact_allproperty=Get-OVRemoteSupportContact -ApplianceConnection $connection | Select-Object *
                    $rs_contact=$rs_contact_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                    @{Name='Name';Expression={$_.firstname+" "+$_.lastname}},@{Name='Email';Expression={$_.email}},@{Name='Phone';Expression={$_.primaryphone}},`
                    @{Name='Default';Expression={$_.default}}
                    Table -Name 'Remote Support Contact' -InputObject $rs_contact -Columns "Appliance","Name","Email","Phone","Default" `
                    -ColumnWidths "20","20","20","20","20" -Headers "Appliance","Name","Email","Phone","Default" -Caption "Remote Support Contact"   
                }
                catch {
                    Write-PScriboMessage -Message "There is no remote support contact information available." 
                    Paragraph "There is no remote support contact information available" -Bold
                }
            }

            Section -Style Heading2 "14.3 Remote Support Data Collection Schedule"{
                try {
                    $dc_schedule_allproperty=Get-OVRemoteSupportDataCollectionSchedule -ApplianceConnection $Connection | Select-Object *
                    $dc_schedule=$dc_schedule_allproperty | Select-Object @{Name='Schedule Name';Expression={$_.schedulename}},`
                    @{Name='Repeat Option';Expression={$_.Repeatoption}},@{Name='Hour';Expression={$_.hourofday}},@{Name='Minute';Expression={$_.minute}},`
                    @{Name='Day of Month';Expression={$_.dayofmonth}},@{Name='Day of week';Expression={$_.dayofweek}}
                    Table -Name 'Remote Support Data Collection Schedule' -InputObject $dc_schedule -Columns "Schedule Name","Repeat Option",`
                    "Hour","Minute","Day of Month","Day of week" -ColumnWidths "16","16","16","16","16","16" -Headers "Schedule Name","Repeat Option",`
                    "Hour","Minute","Day of Month","Day of week" -Caption "Remote Support Data Collection Schedule"
                }
                catch {
                    Write-PScriboMessage -Message "There is no remote support data collection schedule information available." 
                    Paragraph "There is no remote support data collection schedule information available" -Bold
                }
            }

            Section -Style Heading2 "14.4 Remote Suport Default Site"{
                $rs_defaultsite_allproperty=Get-OVRemoteSupportDefaultSite -ApplianceConnection $connection | select-object *
                $rs_defaultsite=$rs_defaultsite_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Street Address1';Expression={$_.Streetaddress1}},@{Name='Street Address2';Expression={$_.Streetaddress2}},`
                @{Name='Province State';Expression={$_.provincestate}},@{Name='Postal Code';Expression={$_.Postalcode}},`
                @{Name='Country';Expression={$_.Countrycode}},@{Name='TimeZone';Expression={$_.timezone}}
                Table -Name 'Remote Suport Default Site' -InputObject $rs_defaultsite -Columns "Appliance","Street Address1",`
                "Street Address2","Province State","Postal Code","Country","Timezone" -ColumnWidths "14","14","14","14","14","14","14" `
                -Headers "Appliance","Street Address1","Street Address2","Province State","Postal Code","Country","Timezone" `
                -Caption "Remote Suport Default Site"
            }

            Section -Style Heading2 "14.5 Remote Entitlement Status"{
                try {
                    $devices=(Get-OVServer -ApplianceConnection $connection).name
                    $support_entitlement_results=foreach($device in $devices){
                    try {
                        $support_entitlement=Get-OVServer -Name $device | Get-OVRemoteSupportEntitlementStatus | Select-Object *
                        
                        $resource_serial_number=$support_entitlement.resourceserialnumber
                        $isentitled=$support_entitlement.isentitled
                        $entitlement_package=$support_entitlement.entitlementpackage
                        $entitlement_status=$support_entitlement.entitlement_status
                        $coverage=$support_entitlement.coveragedays
                        $offerend=$support_entitlement.offerenddate
                    }
                    catch [HPEOneView.Appliance.RemoteSupportResourceException] {
                        Write-PScriboMessage -IsWarning "$($Error[0].Exception.Message)"
                    }
                
                    [PSCustomObject]@{
                        'Resource Name'=$device
                        'Resource SN' = $resource_serial_number
                        'IsEntitled'=$isentitled
                        'Entitlement Package'=$entitlement_package
                        'Entitlement Status'=$entitlement_status
                        'CoverageDays'=$coverage
                        'Offer End Date'=$offerend
                        
                    }
                }
                Table -Name "Support Entitelment Status" -InputObject $support_entitlement_results -Columns 'Resource Name','Resource SN',`
                'IsEntitled','Entitlement Package','Entitlement Status','CoverageDays','Offer End Date' -ColumnWidths "14","14","14","14","14","14","14"`
                -Headers 'Resource Name','Resource SN','IsEntitled','Entitlement Package','Entitlement Status','CoverageDays',`
                'Offer End Date' -Caption "Support Entitlement Status"
                }
                catch {
                    Write-PScriboMessage -Message "There is no information available about remote entitlement status."
                    Paragraph "There is no information available about remote entitlement status." -Bold
                }
                
            }
            
            Section -Style Heading2 "14.6 Remote Support Partner"{
                $remotepartner_allproperty=Get-OVRemoteSupportPartner -ApplianceConnection $connection
                $remote_partner=$remotepartner_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Name';Expression={$_.Name}},@{Name='Partner Type';Expression={$_.Partnertype}},@{Name='City';Expression={$_.city}},`
                @{Name='Country';Expression={$_.country}},@{Name='Default';Expression={$_.default}}

                Table -Name 'Remote Support Partner' -InputObject $remote_partner -Columns "Appliance","Name","Partner type","City","Country",`
                "Default" -ColumnWidths "16","16","16","16","16","16" -Headers "Appliance","Name","Partner type","City","Country","Default" -Caption "Remote Support Partner"
            }

            Section -Style Heading2 "14.7 Remote Syslog"{
                $remote_syslog_allproperty=Get-OVRemoteSyslog -ApplianceConnection $Connection | Select-Object *
                $remote_syslog=$remote_syslog_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Destination';Expression={$_.remoteSyslogDestination}},@{Name='Port';Expression={$_.remoteSyslogPort}},`
                @{Name='Enabled';Expression={$_.enabled}}
                Table -Name "Remote Syslog" -InputObject $remote_syslog -Columns "Appliance","Destination","Port",`
                "Enabled" -ColumnWidths "25","25","25","25" -Headers "Appliance","Destination","Port","Enabled" -Caption "Remote Syslog"
            }

            # Section 15
            BlankLine
            Paragraph -Style Heading3 '15. Hypervisor Manager'
            BlankLine

            Section -Style Heading2 "15.1 Hypervisor Manager"{
                Paragraph "There is no Hypervisor manager information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 16
            BlankLine
            Paragraph -Style Heading3 '16. Interconnect Information'
            BlankLine

            Section -Style Heading2 "16.1 Interconnect"{
                Paragraph "There is no interconnect information available." -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "16.2 Interconnect NTP Configuration"{
                $ntp_config_allproperty=Get-OVInterconnectNTPConfiguration -ApplianceConnection $connection | Select-Object *
                $ntp_config=$ntp_config_allproperty | Select-Object @{Name='Name';Expression={$_.Name}},@{Name='Value';Expression={$_.value}},`
                @{Name='Created';Expression={$_.created}},@{Name='Modified';Expression={$_.modified}},@{Name='Group';Expression={$_.group}}
                Table -Name 'Interconnect NTP Configuration' -InputObject $ntp_config -Columns "Name","Value","Created","Modified","Group" `
                -ColumnWidths "20","20","20","20","20" -Headers "Name","Value","Created","Modified","Group" -Caption "Interconnect NTP Configuration"
            }

            Section -Style Heading2 "16.3 Interconnect Connection type"{
                $inter_ct_allproperty=Get-OVInterconnectType -ApplianceConnection $connection | Select-Object *
                $inter_ct=$inter_ct_allproperty | Select-Object @{Name='Name';Expression={$_.name}},@{Name='Type';Expression={$_.type}},`
                @{Name='Part Number';Expression={$_.Partnumber}},@{Name='State';Expression={$_.state}},@{Name='Status';Expression={$_.status}}
                Table -Name 'Interconnect Connection type' -InputObject $inter_ct -Columns "Name","Type","Part Number","State","Status" `
                -ColumnWidths "20","20","20","20","20" -Headers "Name","Type","Part Number","State","Status" -Caption "Interconnect Connection type"
            }

            # Section 17
            BlankLine
            Paragraph -Style Heading3 '17. Label Information'
            BlankLine

            Section -Style Heading2 "17.1 Oneview Label"{
                Paragraph "There is no oneview label information available." -Bold
                Write-PScriboMessage -Message "There is no oneview label information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 18
            BlankLine
            Paragraph -Style Heading3 '18. Ldap Information'
            BlankLine

            Section -Style Heading2 "18.1 Oneview Ldap"{
                $ldap_allproperty=Get-OVLdap -ApplianceConnection $connection | Select-Object *
                $ldap=$ldap_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Local login';Expression={$_.AllowLocalLogin}},@{Name='Default Directory';Expression={$_.defaultlogindomain.name}},`
                @{Name='Directories';Expression={$_.configuredlogindomains.name -join ","}},@{Name='Login Message';Expression={$_.loginmessage.message}}
                Table -Name 'Oneview Ldap' -InputObject $ldap -Columns "Appliance","Local login","Default directory","Directories","Login Message"`
                 -ColumnWidths "20","20","20","20","20" `
                 -Headers "Appliance","Local login","Default directory","Directories","Login Message" -Caption "Oneview Ldap"
            }

            Section -Style Heading2 "18.2 Ldap Directory"{
                $ldap_dir_allproperty=Get-OVLdapDirectory -ApplianceConnection $connection | Select-Object *
                $ldap_dir=$ldap_dir_allproperty | Select-Object @{Name='Name';Expression={$_.name}},@{Name='Type';Expression={$_.type}},`
                @{Name='BaseDN';Expression={$_.basedn}},@{Name='Directory Servers';Expression={$_.directoryservers.directoryserveripaddress+":"+`
                $_.directoryservers.directoryserversslportnumber}},@{Name='Status';Expression={$_.directoryservers.serverstatus}}
                Table -Name 'Ldap Directory' -InputObject $ldap_dir -Columns "Name","Type","BaseDN","Directory servers","Status" `
                -ColumnWidths "20","20","20","20","20" -Headers "Name","Type","BaseDN","Directory servers","Status" -Caption "Ldap Directory"
            }

            Section -Style Heading2 "18.3 Ldap Group"{
                $ldap_group_allproperty=Get-OVLdapGroup -ApplianceConnection $connection | Select-Object *
                $ldap_group=$ldap_group_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Name';Expression={$_.egroup}},@{Name='Directory';Expression={$_.logindomain}},`
                @{Name='Permissions';Expression={$_.permissions.rolename}}
                Table -Name 'Ldap Group' -InputObject $ldap_group -Columns "Appliance","Name","Directory","Permissions" `
                -ColumnWidths "20","20","20","40" -Headers "Appliance","Name","Directory","Permissions" -Caption "Ldap Group"
            }

            # Section 19
            BlankLine
            Paragraph -Style Heading3 '19. License Information'
            BlankLine

            Section -Style Heading2 "19.1 License"{
                $license_allproperty=Get-OVLicense -ApplianceConnection $connection | Select-Object *
                $license=$license_allproperty | Select-Object @{Name='Product';Expression={$_.product}},@{Name='Type';Expression={$_.type}},`
                @{Name='Capacity';Expression={$_.Capacity}},@{Name='Allocated';Expression={$_.Allocated}},`
                @{Name='Available';Expression={$_.available}},@{Name='Nodes';Expression={$_.Nodes}}
                Table -Name 'License' -InputObject $license -Columns "Product","Type","Capacity","Allocated","Available","Nodes" `
                -ColumnWidths "16","16","16","16","16","16" -Headers "Product","Type","Capacity","Allocated","Available","Nodes" -Caption "License"
            }

            # Section 20
            BlankLine
            Paragraph -Style Heading3 '20. Login Message Information'
            BlankLine

            Section -Style Heading2 "20.1 Login Message"{
                $loginmessage=Get-OVLoginMessage -ApplianceConnection $connection | Select-Object *
                $lm=$loginmessage.message
                Paragraph "$($lm)" -Bold
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 21
            BlankLine
            Paragraph -Style Heading3 '21. Managed San Information'
            BlankLine

            Section -Style Heading2 "21.1 Managed San Information"{
                Paragraph "There is no Managed San information available." -Bold
                Write-PScriboMessage -Message "There is no Managed San information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 22
            BlankLine
            Paragraph -Style Heading3 '22. Network Information'
            BlankLine

            Section -Style Heading2 "22.1 Network"{
                Paragraph "There is no oneview network information available." -Bold
                Write-PScriboMessage -Message "There is no oneview network information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "22.2 Network Set"{
                Paragraph "There is no oneview network set information available." -Bold
                Write-PScriboMessage -Message "There is no oneview network set information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 23
            BlankLine
            Paragraph -Style Heading3 '23. Pending Update Information'
            BlankLine

            Section -Style Heading2 "23.1 Pending Updates"{
                Paragraph "There is no pending updates information available." -Bold
                Write-PScriboMessage -Message "There is no pending updates information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 24
            BlankLine
            Paragraph -Style Heading3 '24. xAPI Information'
            BlankLine

            Section -Style Heading2 "24.1 xAPI version"{
                $xapiversion_allproperty=Get-OVXApiVersion -ApplianceConnection $connection | Select-Object *
                $xapiversion=$xapiversion_allproperty | Select-Object @{Name='Appliance';Expression={$_.ApplianceConnection}},`
                @{Name='Current Version';Expression={$_.currentversion}},@{Name='Minimum Version';Expression={$_.minimumversion}}
                Table -Name 'xAPI version' -InputObject $xapiversion -Columns "Appliance","Current version","Minimum version" `
                -ColumnWidths "20","30","30" -Headers "Appliance","Current version","Minimum version" -Caption "xAPI version"
            }

            # Section 25
            BlankLine
            Paragraph -Style Heading3 '25. Oneview Version'
            BlankLine

            Section -Style Heading2 "25.1 Oneview Version"{
                $ovversion_allproperty=Get-OVVersion -ApplianceConnection $connection | Select-Object *
                $name=$connection.name
                $ovversion=$ovversion_allproperty | Select-Object `
                @{Name='Appliance Version';Expression={[string]$($_.$name.applianceversion.major)+"."+[string]$($_.$name.applianceversion.minor)`
                +"."+[string]$($_.$name.applianceversion.build)+"."+[string]$($_.$name.applianceversion.revision)+"."+`
                [string]$($_.$name.applianceversion.patch)}},`
                @{Name='Model Number';Expression={$_.$name.modelnumber}},@{Name='Library Version';Expression={$_.libraryversion}},
                @{Name='Path';Expression={$_.path}}
                Table -Name 'Oneview Version' -InputObject $ovversion -Columns "Appliance Version","Model Number","Library version","Path" `
                -ColumnWidths "20","30","30","20" -Headers "Appliance Version","Model Number","Library version","Path" -Caption "Oneview Version"
            }

            
            # Section 26
            BlankLine
            Paragraph -Style Heading3 '26. User information'
            BlankLine

            Section -Style Heading2 "26.1 Users"{
                $user_allproperty=Get-OVuser -applianceconnection $connection | Select-Object *
                $user=$user_allproperty | select-object @{Name='Name';Expression={$_.username}},@{Name='Enabled';Expression={$_.enabled}},`
                @{Name='Role';Expression={$_.permissions.rolename}},@{Name='Email';Expression={$_.emailaddress}}
                Table -Name 'User information' -InputObject $user -Columns "Name","Enabled","Role","Email" -ColumnWidths "25","25","25","25"`
                -Headers "Name","Enabled","Role","Email" -Caption "User information"
            }

            # Section 27
            BlankLine
            Paragraph -Style Heading3 '27. UplinkSet Information'
            BlankLine

            Section -Style Heading2 "27.1 Uplink Set"{
                Paragraph "There is no uplink set information available." -Bold
                Write-PScriboMessage -Message "There is no uplink set information available."
                #Table -Name 'UplinkSet Information' -InputObject -Columns -ColumnWidths `
                #-Headers "UplinkSet Information" -Caption "UplinkSet Information"
            }

            # Section 28
            BlankLine
            Paragraph -Style Heading3 '28. Oneview Unmanaged devices'
            BlankLine

            Section -Style Heading2 "28.1 Unmanaged Devices"{
                Paragraph "There is no unmanaged devices information available." -Bold
                Write-PScriboMessage -Message "There is no unmanaged devices information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 29
            BlankLine
            Paragraph -Style Heading3 '29. Oneview task status'
            BlankLine

            Section -Style Heading2 "29.1 Oneview task status - 5 Days"{
                $ovtask_allproperty=get-ovtask -applianceconnection $connection | select-object *
                $ovtask=$ovtask_allproperty | Where-Object {[datetime]$_.created -gt (get-date).adddays(-5)} |`
                select-object @{Name='Name';Expression={$_.name}},@{Name='Owner';Expression={$_.Owner}},@{Name='created';Expression={$_.created}},`
                @{Name='Duration';Expression={$_.expectedduration}},@{Name='Task State';Expression={$_.TaskState}},`
                @{Name='Percent Complete';Expression={$_.percentcomplete}}
                Table -Name 'Oneview task status' -InputObject $ovtask -Columns "Name","Owner","Created","Duration","Task State","Percent Complete" `
                -ColumnWidths "16","16","16","16","16","16" -Headers "Name","Owner","Created","Duration","Task State","Percent Complete" `
                -Caption "Oneview task status"
            }
            
            # Section 30
            BlankLine
            Paragraph -Style Heading3 '30. Oneview switch information'
            BlankLine

            Section -Style Heading2 "30.1 Switch information"{
                Paragraph "There is no switch information available." -Bold
                Write-PScriboMessage -Message "There is no switch information available."
                #Table -Name 'Oneview switch information' -InputObject -Columns -ColumnWidths -Headers -Caption "Oneview switch information"
            }

            Section -Style Heading2 "30.2 Switch type information"{
                $switch_allproperty=get-ovswitchtype -applianceconnection $connection | select-object *
                $switchtype=$switch_allproperty | select-object @{Name='Name';Expression={$_.name}},@{Name='Part Number';Expression={$_.partnumber}},`
                @{Name='Minimum firmware version';Expression={$_.minimumfirmwareversion}},`
                @{Name='Maximum firmware version';Expression={$_.MaximumFirmareVersion}}
                Table -Name 'Switch type' -InputObject $switchtype -Columns "Name","Part number","Minimum firmware version","Maximum firmware version"`
                -ColumnWidths "20","20","40","20" -Headers "Name","Part number","Minimum firmware version","Maximum firmware version" `
                -Caption "Switch types"
            }

            # Section 31
            BlankLine
            Paragraph -Style Heading3 '31. Oneview SPP File Information'
            BlankLine

            Section -Style Heading2 "31.1 Oneview SPP File"{
                $sppfile_allproperty=get-ovsppfile -applianceconnection $connection | select-object *
                $sppfile= $sppfile_allproperty | select-object @{Name='Name';Expression={$_.name}},@{Name='State';Expression={$_.state}},`
                @{Name='Status';Expression={$_.status}},@{Name='Version';Expression={$_.version}},@{Name='ISOFileName';Expression={$_.isofilename}},`
                @{Name='XMLkeyName';Expression={$_.XMLKeyName}},@{Name='BundleSize';Expression={$_.bundlesize}}
                Table -Name 'Oneview SPP File' -InputObject $sppfile -Columns "Name","State","Status","Version","ISOFileName","XMLKeyName","BundleSize"`
                -ColumnWidths "14","14","14","14","14","14","14" -Headers "Name","State","Status","Version","ISOFileName",`
                "XMLKeyName","BundleSize" -Caption "Oneview SPP File"
            }

            # Section 32
            BlankLine
            Paragraph -Style Heading3 '32. Oneview Power Information'
            BlankLine

            Section -Style Heading2 "32.1 Power Device"{
                Paragraph "There is no power device information available." -Bold
                Write-PScriboMessage -Message "There is no power device information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "32.2 Power Potential device connection"{
                Paragraph "There is no power potential device connection information available." -Bold
                Write-PScriboMessage -Message "There is no power potential device connection information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 33
            BlankLine
            Paragraph -Style Heading3 '33. Profile Information'
            BlankLine

            Section -Style Heading2 "33.1 Oneview Profile"{
                try {
                    $ovprofile_allproperty=get-ovprofile -applianceconnection $connection | select-object *
                    $ovprofile =$ovprofile_allproperty | select-object @{Name='Name';Expression={$_.name}},@{Name='Status';Expression={$_.status}},`
                    @{Name='Compliance';Expression={$_.templateCompliance}},@{Name='Type';Expression={$_.type}},@{Name='Created';Expression={$_.created}},`
                    @{Name='Modified';Expression={$_.modified}}
                    if(!$ovprofile){
                        throw
                    }
                    Table -Name 'Oneview Profile' -InputObject $ovprofile -Columns "Name","Status","Compliance","Type","Created","Modified" `
                    -ColumnWidths "16","16","16","16","16","16" -Headers "Name","Status","Compliance","Type","Created","Modified" -Caption "OneView Profile"   
                }
                catch {
                    Paragraph "There is no profile information available." -Bold
                    Write-PScriboMessage -Message "There is no profile information available."
                }
            }

            Section -Style Heading2 "33.2 Profile Connection list"{
                Paragraph "There is no profile connection list information available." -Bold
                Write-PScriboMessage -Message "There is no profile connection list information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 34
            BlankLine
            Paragraph -Style Heading3 '34. Rack Information'
            BlankLine

            Section -Style Heading2 "34.1 Rack details"{
                Paragraph "There is no rack information available." -Bold
                Write-PScriboMessage -Message "There is rack information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "34.2 Rack Manager"{
                Paragraph "There is no rack manager information available." -Bold
                Write-PScriboMessage -Message "There is no rack manager information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 35
            BlankLine
            Paragraph -Style Heading3 '35. SAN Information'
            BlankLine

            Section -Style Heading2 "35.1 SAN Manager"{
                Paragraph "There is no san manager information available." -Bold
                Write-PScriboMessage -Message "There is no san manager information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            Section -Style Heading2 "35.2 SAN Zone"{
                Paragraph "There is no san zone information available." -Bold
                Write-PScriboMessage -Message "There is no san zone information available."
                #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
            }

            # Section 36
            BlankLine
            Paragraph -Style Heading3 '36. SAS Information'
            BlankLine

            Section -Style Heading2 "36.1 SAS Interconnect Type"{
                try {
                    #get-ovsasinterconnecttype -applianceconnection $connection | Out-Null
                    Paragraph "There is no sas interconnect type information available." -Bold
                    Write-PScriboMessage -Message "There is no sas interconnect type information available."
                    #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption   
                }
                catch {
                    Paragraph "There is no sas interconnect type information available." -Bold
                    Write-PScriboMessage -Message "There is no sas interconnect type information available."
                }
            }

            Section -Style Heading2 "36.2 SAS Logical Interconnect"{
                try {
                    get-ovsaslogicalinterconnect -applianceconnection $connection | Out-Null
                    #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
                }
                catch {
                    Paragraph "There is no sas logical interconnect information available." -Bold
                    Write-PScriboMessage -Message "There is no sas logical interconnect information available."
                }
            }

            # Section 37
            BlankLine
            Paragraph -Style Heading3 '37. Storage Information'
            BlankLine

            Section -Style Heading2 "37.1 Storage Pool"{
                try {
                    if(!Get-OVStoragePool -applianceconnection $connection){
                        throw
                    }
                    #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption   
                }
                catch {
                    Paragraph "There is no Storage pool information available." -Bold
                    Write-PScriboMessage -Message "There is no Storage pool information available."
                }
            }

            Section -Style Heading2 "37.2 Storage System"{
                try {
                    if(!Get-OVStorageSystem -applianceconnection $connection){
                        throw
                    }
                    #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption   
                }
                catch {
                    Paragraph "There is no Storage system information available." -Bold
                    Write-PScriboMessage -Message "There is no Storage system information available."
                }
            }

            Section -Style Heading2 "37.3 Storage Volume"{
                try {
                    if(!Get-OVStorageVolume -applianceconnection $connection){
                        throw
                    }
                    #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption   
                }
                catch {
                    Paragraph "There is no Storage volume information available." -Bold
                    Write-PScriboMessage -Message "There is no Storage volume information available."
                }
            }

            Section -Style Heading2 "37.4 Storage Volume Set"{
                try {
                    if(!Get-OVStorageVolumeSet -applianceconnection $connection){
                        throw
                    }
                    #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption   
                }
                catch {
                    Paragraph "There is no Storage volume set information available." -Bold
                    Write-PScriboMessage -Message "There is no Storage volume set information available."
                }
            }

            Section -Style Heading2 "37.5 Storage Volume Snapshot"{
                try {
                    if(!Get-OVStorageVolumeSnapShot -applianceconnection $connection){
                        throw
                    }
                    #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption   
                }
                catch {
                    Paragraph "There is no Storage volume snapshot information available." -Bold
                    Write-PScriboMessage -Message "There is no Storage volume snapshot information available."
                }
            }

            Section -Style Heading2 "37.6 Storage Volume template"{
                try {
                    if(!Get-OVStorageVolumeTemplate -applianceconnection $connection){
                        throw
                    }
                    #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption   
                }
                catch {
                    Paragraph "There is no Storage volume template information available." -Bold
                    Write-PScriboMessage -Message "There is no Storage volume template information available."
                }
            }

            Section -Style Heading2 "37.7 Storage Volume template policy"{
                try {
                    if(!Get-OVStorageVolumeTemplatePolicy -applianceconnection $connection){
                        throw
                    }
                    #Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption   
                }
                catch {
                    Paragraph "There is no Storage volume template policy information available." -Bold
                    Write-PScriboMessage -Message "There is no Storage volume template policy information available."
                }
            }
            <#
                @{Name='';Expression={}}
                Section -Style Heading2 ""{
                    Table -Name '' -InputObject -Columns -ColumnWidths -Headers -Caption
                }
                Write-PScriboMessage -Message "There is no enclosure group information available"
            #>
        }
        $document | Export-Document -Path .\ -Format Word,Html,Text -Verbose
    }
    end {
        Disconnect-OVMgmt -Hostname $manual_ip
        Write-Host "Disconnected the session with $($manual_ip)" -ForegroundColor Yellow
        Write-Host "AsBuilt document for oneview successfully successfully created." -ForegroundColor Yellow   
    }
}

# Main

#Implementing Nuget provider
if(!(Get-PackageProvider -ListAvailable | Where-Object{$_.name -eq "nuget"})){
    Write-host "[ $($date) ] Copying Nuget package provider form $($psscriptroot) to "C:\Program Files\PackageManagement\ProviderAssemblies\"" `
    -ForegroundColor Yellow
    Get-ChildItem -Path $psscriptroot | Where-Object {$_.name -eq "Nuget" -and $_.psiscontainer -eq $true} | `
    Copy-Item -Destination "C:\Program Files\PackageManagement\ProviderAssemblies" -Force -Recurse
    Write-host "[ $($date) ] Importing Nuget package provider" -ForegroundColor Yellow
    Import-PackageProvider nuget | Out-Null
    Write-host "[ $($date) ] Sucessfully imported nuget package provider" -ForegroundColor Yellow
}


# Copy pasting required module in module path
foreach($path in $env:PSModulePath.Split(";") | Where-Object {$_ -notlike "C:\program files\windowsapps\*"}){
    foreach($required_module in $required_modules){
        Write-host "[ $($date) ] Importing $($required_module) in powershell current session" -ForegroundColor Yellow
        Write-host "[ $($date) ] $($required_module) not found, copying it from $($psscriptroot) to $($path)" -ForegroundColor Yellow
        Get-ChildItem -Path $psscriptroot | Where-Object {$_.name -eq $required_module -and $_.psiscontainer -eq $true} | `
        Copy-Item -Destination $path -Recurse -Force
        Write-Host "[ $($date) ] Successfully copied $($required_module) from $psscriptroot to $($path)" -ForegroundColor Yellow
    }
}

Write-Banner -FontSize 10 "Auto OneView"
Write-Host '---------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host '                   Welcome to Oneview Automation                           ' -ForegroundColor Cyan
Write-Host '---------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host `n
Import-Module PSMenu

# getting oneview version module imported
Write-Host "Please select oneview version : " -ForegroundColor Cyan
$oneview_version=Show-Menu @("800","720","710","700","630","620","610","600",$(Get-MenuSeparator), "Quit")
$oneview_module=$("HPEOneview"+"."+$oneview_version)
Get-Module -ListAvailable | Where-Object {$_.name -like "HPEOneview.*"} | Remove-Module -Force

foreach($path in $env:PSModulePath.Split(";") | Where-Object {$_ -notlike "C:\program files\windowsapps\*"}){
        Write-host "[ $($date) ] Importing $($oneview_module) in powershell current session" -ForegroundColor Yellow
        Import-Module $required_module
        Write-host "[ $($date) ] $($oneview_module) not found, copying it from $($psscriptroot) to $($path)" -ForegroundColor Yellow
        Get-ChildItem -Path $psscriptroot | Where-Object {$_.name -eq $oneview_module -and $_.psiscontainer -eq $true} | `
        Copy-Item -Destination $path -Recurse -Force
        Write-Host "[ $($date) ] Successfully copied $($oneview_module) from $psscriptroot to $($path)" -ForegroundColor Yellow
}
Write-Host "`n"
<#
Write-Host "Please select one of the option to continue"
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
                #set-multiops -Operation Text -pscredential $pscredential -textfilepath $text_path
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
        #set-multiops -Operation CSV -CSVfilepath $csv_path
    }
    "Manual IPs"{
        Write-Host `n
        $manual_ips_ns=Read-Host "Enter Manual IPs separated by comma"
        Write-Host "Entered manual IPs are $($manual_ips)" -ForegroundColor Cyan
        $manual_ips=$manual_ips_ns.Split(',')
        $User=Read-Host "Enter username"
        $password=Read-Host "Enter Password" -AsSecureString
        $pscredential = New-Object System.Management.Automation.PSCredential($User,$password)
        #set-multiops -Operation Manual -pscredential $credential -ManualIPs $manual_ips
    }
    "Quit" {
        Write-Host `n
        Write-Host "User has quit the operation" -ForegroundColor Red
        return
    }
}
#>

try {
        $manual_ips_ns=Read-Host "Enter target IP of oneview"
        Write-Host "Entered target IP is $($manual_ips_ns)" -ForegroundColor Cyan
        $manual_ips=$manual_ips_ns.Split(',')
        $User=Read-Host "Enter username"
        $password=Read-Host "Enter Password" -AsSecureString
        $pscredential = New-Object System.Management.Automation.PSCredential($User,$password)
        foreach($manual_ip in $manual_ips){
            get-asbuilt -pscredential $pscredential
        }
        
}
catch {
    Write-Host $($Error[0].Exception.Message) -ForegroundColor Red
}
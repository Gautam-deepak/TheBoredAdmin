# variables 

$scriptroot="C:\script"
$Admingroups=@("Domain Admins","Enterprise Admins","Administrators")
#Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name -ExpandProperty name | Set-Content -Path $scriptroot\domainadmin.txt -force
#Get-ADGroupMember -Identity "Enterprise Admins" | Select-Object Name -ExpandProperty name | Set-Content -Path $scriptroot\Enterpriseadmin.txt -force
#Get-ADGroupMember -Identity "Administrators" | Select-Object Name -ExpandProperty name | Set-Content -Path $scriptroot\Administrators.txt -force
$logFile = "$scriptroot\adminchangealert.log"
$EmailFrom=""
$domain=""
$date=Get-Date
$Global:counter=0
$Global:message=$null
$ErrorActionPreference="stop"


# Functions
Function Write-Log {
<#
    .SYNOPSIS
    Describe purpose of "Write-Log" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER messages
    Describe parameter -messages.

    .PARAMETER level
    Describe parameter -level.

    .EXAMPLE
    Write-Log -messages Value -level Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Write-Log

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
#>

  param(
      [Parameter(Mandatory = $true,HelpMessage='Add help message for user')][string[]] $messages,
      [Parameter(Mandatory = $false)]
      [ValidateSet("INFO","WARN","ERROR")]
      [string] $level = "INFO"
  )

  # Create timestamp
  $timestamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")

  # Append content to log file
  foreach($message in $messages){
  Add-Content -Path $logFile -Value "$timestamp [$level] - $message"
  }
}
Function Get-status{
<#
    .SYNOPSIS
    Describe purpose of "Get-status" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER message
    Describe parameter -message.

    .EXAMPLE
    Get-status -message Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-status

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
#>

  param(
      [parameter(Mandatory=$true,HelpMessage='Add help message for user')][string]$message
  )
  if( $? -eq $true ) {
      $messagefinal=$message+'- success'
      Write-log -level INFO -message $messagefinal
  
  } else {
      $messagefinal=$message+'- failed'
      Write-log -level ERROR -message $messagefinal
  }
}  

Function Get-difference{

    <#
    .SYNOPSIS
    Describe purpose of "Get-status" in 1-2 sentences.

    .DESCRIPTION
    Add a more complete description of what the function does.

    .PARAMETER message
    Describe parameter -message.

    .EXAMPLE
    Get-status -message Value
    Describe what this call does

    .NOTES
    Place additional notes here.

    .LINK
    URLs to related sites
    The first link is opened by Get-Help -Online Get-status

    .INPUTS
    List of input types that are accepted by this function.

    .OUTPUTS
    List of output types produced by this function.
#>
 
    [cmdletbinding()]
    param(
        
        # Parameter help description
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, `
        ValueFromPipelineByPropertyName=$true, HelpMessage="All admin groups")]
        [string[]]
        $Admingroups
    )

    begin{
        Write-Log -messages "Calculating differences in all admin groups"
    }
    process{
        
        try {

            foreach($Admingroup in $Admingroups){
            
                If($Admingroup -eq "Domain Admins"){ $file="domainadmin.txt"}
    
                elseif ($Admingroup -eq "Enterprise Admins") { $file="Enterpriseadmin.txt"}
    
                else{ $file="Administrators.txt" }
    
                $Member=Get-Content -Path $scriptroot\$file
                $CurGrpMember=Get-ADGroupMember -Identity $Admingroup | Select-Object Name -ExpandProperty name
                $difference=Compare-Object -ReferenceObject $Member -DifferenceObject $CurGrpMember
    
                If($null -eq $difference){
                    $Global:counter+=1
                    $Global:message+="There are no changes in $($Admingroup) group. "
                }
    
                If($difference.sideindicator -contains "=>"){
                    $added=($difference | Where-Object {$_.sideindicator -eq "=>"}).inputobject
                    $addjoined=$added -join ","
                    $addcount=$added.count
                    $Global:message+="`n $addcount new members are added in the $($Admingroup) Group : $addjoined ."
                }
      
                if($difference.sideindicator -contains "<="){
                    $remove=($difference | Where-Object {$_.sideindicator -eq "<="}).inputobject
                    $removejoined=$remove -join "," 
                    $removecount=$remove.count
                    $Global:message+="`n $removecount new members are removed in the $($Admingroup) Group : $removejoined ."
                }

                $CurGrpMember | Set-Content -Path $scriptroot\$file -Force
                Clear-Variable difference,CurGrpMember
            }
        }
    catch {
        write-log -message ('Error in difference Operation:{0} :{1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
    }
    finally {
        $ErrorActionPreference="continue"
        Write-Log -messages "difference calculated and finished"
    }
}
    end{
        write-log -messages $Global:message
    }
}
Function Send-email{
    
    begin{
        # Getting encrypted password
        $encrypted=Get-Content $scriptroot\password.txt | ConvertTo-SecureString -Key (Get-Content $scriptroot\aeskey.key)
        # Using the saved password and username in the credential
        $credential = New-Object System.Management.Automation.PSCredential($EmailFrom,$encrypted)

        # Or we can use xml for credentials encryption 
        <#
        $credential=get-credential (run once)
        $credential | Export-Clixml -Path $scriptroot\${env:username}_${env:computername}.xml (run once)
        $credential = Import-Clixml -Path $scriptroot\${env:username}_${env:computername}.xml
        #>

        [Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12
        $body1="Hello All,`n`nPlease find the current status of admin groups for $domain dated $date. "
        $body=$body1+$Global:message
    }
        
    process{
        # If there are no changes in any of the admin groups, counter value will be 3. So sending an email , if value is not 3 that means - At change.
        
        try {
            if($counter -ne 3){
                $params=@{
                To=""
                CC=""
                From=$EmailFrom
                Credential=$credential
                Body=$body
                Subject='Alert : AD Admin Group Members Change (Add/Remove)'
                SmtpServer='smtp.office365.com'
                Port=587
                UseSsl=$true
                Attachments="$scriptroot\domainadmin.txt","$scriptroot\Administrators.txt","$scriptroot\Enterpriseadmin.txt"
                }  
                Send-MailMessage @params
                Write-Log -messages "Email sent"
            }  
            else{
                write-log -messages "Email not sent as there are no changes"
            }
        }
        catch {
            write-log -message ('Error in Email Operation:{0} :{1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
        }      
    }
    end{
        Write-Log -messages "Script run finished"
    }
}
    
    
# Main
Get-difference -Admingroups $Admingroups
Send-email
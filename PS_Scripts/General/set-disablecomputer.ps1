# Disable computers if they stay in computers container for more than 7 days

#Variables

$destinationOU="OU=Disable_Computer,DC=nova,DC=com"
$computers=Get-ADComputer -SearchBase "CN=Computers,DC=NOVA,DC=COM" -Filter 'Enabled -eq $true' -Properties whencreated | `
Where-Object {$_.whencreated -le (get-date).AddDays(-7)} | Select-Object Name -ExpandProperty Name
$scriptpath="C:\windows\system32\script"
$logFile = "$scriptpath\MoveDisableComputers.log"
$EmailFrom=""
$domain="nova.COM"
$date=Get-Date
$body="Hello All,`n`nPlease find the current status of Computers container for $domain dated $date.`n`nRegards `nUPL Automation Account"
$joined=$computers -join ","

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
        
        if($null -ne $computers){
            $body="Hello All,`n`nPlease find the current status of Computers container for $domain dated $date.`
            `nFollowing computers were disabled from default computers container : $joined `n`nRegards `nUPL Automation Account"
          }
          else {
              $body="Hello All,`n`nPlease find the current status of Computers container for $domain dated $date.`
            `nNone of the computers were disabled from default computers container today. `n`nRegards `nUPL Automation Account"
              write-log -messages "None of the computers were disabled from default computers container today"
          }
          
    }
        
    process{
        # If there are no changes in any of the admin groups, counter value will be 3. So sending an email , if value is not 3 that means - At change.
        
        try {
            
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
        catch {
            write-log -message ('Error in Email Operation:{0} :{1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
        }      
    }
    end{
        Write-Log -messages "Script run finished"
    }
}

#Main

try {
    foreach($computer in $computers){
        Set-ADComputer -Identity $computer -Enabled:$false
        Get-status -message "Set $computer disable"
        Move-ADObject -Identity (Get-ADComputer -Identity $computer) -TargetPath $destinationOU
        Get-status -message "Move $computer to Non-sync OU"
    }
}
catch {
    write-log -message ('Error in disable Operation:{0} :{1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
}
finally {
    $ErrorActionPreference='Continue'
    Get-ADComputer -SearchBase "CN=Computers,Dc=nova,dc=com" -Filter * -Properties Enabled | `
    Export-Csv -Path $scriptpath\Computers.csv -Force -NoTypeInformation
    $error.Clear()
}

Send-email
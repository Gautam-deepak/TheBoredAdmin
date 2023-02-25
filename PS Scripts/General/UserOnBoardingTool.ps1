#region ScriptForm Designer

#region Constructor

[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

#endregion

#region Post-Constructor Custom Code

#endregion

#region Form Creation
#Warning: It is recommended that changes inside this region be handled using the ScriptForm Designer.
#When working with the ScriptForm designer this region and any changes within may be overwritten.
#~~< Form1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Form1 = New-Object System.Windows.Forms.Form
$Form1.ClientSize = New-Object System.Drawing.Size(507, 398)
$Form1.Text = "ITOC User Onboarding Tool"
#~~< resultslabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$resultslabel = New-Object System.Windows.Forms.Label
$resultslabel.Location = New-Object System.Drawing.Point(25, 366)
$resultslabel.Size = New-Object System.Drawing.Size(447, 23)
$resultslabel.TabIndex = ""
$resultslabel.Text = ""
$resultslabel.TextAlign = [System.Drawing.ContentAlignment]::TopCenter
$resultslabel.add_Click({resultsclick($resultslabel)})
#~~< logonnameupntextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$logonnameupntextbox = New-Object System.Windows.Forms.TextBox
$logonnameupntextbox.Location = New-Object System.Drawing.Point(290, 135)
$logonnameupntextbox.ReadOnly = $true
$logonnameupntextbox.Size = New-Object System.Drawing.Size(182, 20)
$logonnameupntextbox.TabIndex = ""
$logonnameupntextbox.Text = "@"+$env:USERDNSDOMAIN
$logonnameupntextbox.add_TextChanged({LogonnameupntextboxTextChanged($logonnameupntextbox)})
#~~< LogonNameTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$LogonNameTextbox = New-Object System.Windows.Forms.TextBox
$LogonNameTextbox.Location = New-Object System.Drawing.Point(132, 135)
$LogonNameTextbox.Size = New-Object System.Drawing.Size(138, 20)
$LogonNameTextbox.TabIndex = 4
$LogonNameTextbox.Text = ""
$LogonNameTextbox.add_TextChanged({LogonNameTextboxTextChanged($LogonNameTextbox)})
#~~< InitialTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$InitialTextBox = New-Object System.Windows.Forms.TextBox
$InitialTextBox.Location = New-Object System.Drawing.Point(132, 57)
$InitialTextBox.Size = New-Object System.Drawing.Size(94, 20)
$InitialTextBox.TabIndex = 1
$InitialTextBox.Text = ""
$InitialTextBox.add_TextChanged({InitialTextBoxChanged($InitialTextBox)})
#~~< Createbutton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Createbutton = New-Object System.Windows.Forms.Button
$Createbutton.Enabled = $true
$Createbutton.Location = New-Object System.Drawing.Point(150, 320)
$Createbutton.Size = New-Object System.Drawing.Size(199, 35)
$Createbutton.TabIndex = 8
$Createbutton.Text = "CREATE USER"
$Createbutton.UseVisualStyleBackColor = $true
$Createbutton.add_Click({createbuttonClick($Createbutton)})
#~~< domainPretextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$domainPretextbox = New-Object System.Windows.Forms.TextBox
$domainPretextbox.Location = New-Object System.Drawing.Point(273, 281)
$domainPretextbox.Size = New-Object System.Drawing.Size(199, 20)
$domainPretextbox.TabIndex = 7
$domainPretextbox.Text = ""
$domainPretextbox.add_TextChanged({DomainPretextboxTextChanged($domainPretextbox)})
#~~< logonPretextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$logonPretextbox = New-Object System.Windows.Forms.TextBox
$logonPretextbox.Location = New-Object System.Drawing.Point(25, 281)
$logonPretextbox.ReadOnly = $true
$logonPretextbox.Size = New-Object System.Drawing.Size(232, 20)
$logonPretextbox.TabIndex = ""
$logonPretextbox.Text = $env:USERDOMAIN+"\"
$logonPretextbox.add_TextChanged({LogonPretextboxTextChanged($logonPretextbox)})
#~~< Label1 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Label1 = New-Object System.Windows.Forms.Label
$Label1.Location = New-Object System.Drawing.Point(25, 249)
$Label1.Size = New-Object System.Drawing.Size(274, 20)
$Label1.TabIndex = ""
$Label1.Text = "User logon name (pre-Windows 2000):"
#~~< EmailTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$EmailTextBox = New-Object System.Windows.Forms.TextBox
$EmailTextBox.Location = New-Object System.Drawing.Point(132, 211)
$EmailTextBox.Size = New-Object System.Drawing.Size(340, 20)
$EmailTextBox.TabIndex = 6
$EmailTextBox.Text = ""
$EmailTextBox.add_TextChanged({EmailTextBoxTextChanged($EmailTextBox)})
#~~< EmailLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$EmailLabel = New-Object System.Windows.Forms.Label
$EmailLabel.Location = New-Object System.Drawing.Point(25, 214)
$EmailLabel.Size = New-Object System.Drawing.Size(83, 20)
$EmailLabel.TabIndex = ""
$EmailLabel.Text = "HPE Email:"
#~~< ManagerCombo >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ManagerCombo = New-Object System.Windows.Forms.ComboBox
$ManagerCombo.FormattingEnabled = $true
$ManagerCombo.Location = New-Object System.Drawing.Point(132, 175)
$ManagerCombo.SelectedIndex = -1
$ManagerCombo.Size = New-Object System.Drawing.Size(340, 21)
$ManagerCombo.TabIndex = 5
$ManagerCombo.Text = ""
$ManagerCombo.add_MouseClick({Managercomboclick($ManagerCombo)})
$ManagerCombo.add_SelectedIndexChanged({ManagerComboSelectedIndexChanged($ManagerCombo)})
$ManagerCombo.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList;
#~~< ManagerLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ManagerLabel = New-Object System.Windows.Forms.Label
$ManagerLabel.Location = New-Object System.Drawing.Point(25, 175)
$ManagerLabel.Size = New-Object System.Drawing.Size(83, 18)
$ManagerLabel.TabIndex = ""
$ManagerLabel.Text = "Manager :"
#~~< FullNameTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$FullNameTextbox = New-Object System.Windows.Forms.TextBox
$FullNameTextbox.Location = New-Object System.Drawing.Point(132, 99)
$FullNameTextbox.Size = New-Object System.Drawing.Size(340, 20)
$FullNameTextbox.TabIndex = 3
$FullNameTextbox.Text = ""
$FullNameTextbox.add_TextChanged({FullNameTextboxTextChanged($FullNameTextbox)})
#~~< FullNameLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$FullNameLabel = New-Object System.Windows.Forms.Label
$FullNameLabel.Location = New-Object System.Drawing.Point(25, 99)
$FullNameLabel.Size = New-Object System.Drawing.Size(101, 20)
$FullNameLabel.TabIndex = ""
$FullNameLabel.Text = "Display name:"
#~~< logonnameLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$logonnameLabel = New-Object System.Windows.Forms.Label
$logonnameLabel.Location = New-Object System.Drawing.Point(25, 135)
$logonnameLabel.Size = New-Object System.Drawing.Size(101, 21)
$logonnameLabel.TabIndex = ""
$logonnameLabel.Text = "Logon name:"
#~~< InitialsLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$InitialsLabel = New-Object System.Windows.Forms.Label
$InitialsLabel.Location = New-Object System.Drawing.Point(25, 56)
$InitialsLabel.Size = New-Object System.Drawing.Size(74, 21)
$InitialsLabel.TabIndex =""
$InitialsLabel.Text = "Initials:"
#~~< LastNameTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$LastNameTextbox = New-Object System.Windows.Forms.TextBox
$LastNameTextbox.Location = New-Object System.Drawing.Point(343, 57)
$LastNameTextbox.Size = New-Object System.Drawing.Size(129, 20)
$LastNameTextbox.TabIndex = 2
$LastNameTextbox.Text = ""
$LastNameTextbox.add_TextChanged({LastNameTextboxTextChanged($LastNameTextbox)})
#~~< LastNameLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$LastNameLabel = New-Object System.Windows.Forms.Label
$LastNameLabel.Location = New-Object System.Drawing.Point(232, 60)
$LastNameLabel.Size = New-Object System.Drawing.Size(105, 17)
$LastNameLabel.TabIndex = ""
$LastNameLabel.Text = "Last name:"
#~~< FirstnameTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$FirstnameTextbox = New-Object System.Windows.Forms.TextBox
$FirstnameTextbox.Location = New-Object System.Drawing.Point(132, 17)
$FirstnameTextbox.Size = New-Object System.Drawing.Size(340, 20)
$FirstnameTextbox.TabIndex = 0
$FirstnameTextbox.Text = ""
$FirstnameTextbox.add_TextChanged({FirstnameTextboxTextChanged($FirstnameTextbox)})
#~~< firstnamelabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$firstnamelabel = New-Object System.Windows.Forms.Label
$firstnamelabel.Location = New-Object System.Drawing.Point(25, 17)
$firstnamelabel.Size = New-Object System.Drawing.Size(101, 20)
$firstnamelabel.TabIndex = ""
$firstnamelabel.Text = "First name:"
$Form1.Controls.Add($resultslabel)
$Form1.Controls.Add($logonnameupntextbox)
$Form1.Controls.Add($LogonNameTextbox)
$Form1.Controls.Add($InitialTextBox)
$Form1.Controls.Add($Createbutton)
$Form1.Controls.Add($domainPretextbox)
$Form1.Controls.Add($logonPretextbox)
$Form1.Controls.Add($Label1)
$Form1.Controls.Add($EmailTextBox)
$Form1.Controls.Add($EmailLabel)
$Form1.Controls.Add($ManagerCombo)
$Form1.Controls.Add($ManagerLabel)
$Form1.Controls.Add($FullNameTextbox)
$Form1.Controls.Add($FullNameLabel)
$Form1.Controls.Add($logonnameLabel)
$Form1.Controls.Add($InitialsLabel)
$Form1.Controls.Add($LastNameTextbox)
$Form1.Controls.Add($LastNameLabel)
$Form1.Controls.Add($FirstnameTextbox)
$Form1.Controls.Add($firstnamelabel)
$Form1.add_Load({Form1Load($Form1)})

#endregion

#region Custom Code
$scriptdirectory = "C:\Temp"

$scriptpath="C:\Windows\system32\UserOnboarding.ps1"

$logFile = "$scriptdirectory\Pwdlogs.log"

$ErrorActionPreference='silentlycontinue'

$WarningPreference='silentlycontinue'

$VerbosePreference = 'silentlycontinue'

Import-Module ActiveDirectory
$users = get-aduser -filter 'enabled -eq "True" -and PasswordNeverexpires -eq "False"' -properties mail, displayname | `
Where-Object {$_.displayname -ne $null}| Sort-Object displayname

$group=Get-ADGroup -identity "remote desktop users"

$ManagerCombo.DataSource = [System.Collections.ArrayList] $users
$ManagerCombo.DisplayMember = "DisplayName"
$ManagerCombo.AutoCompleteSource = 'ListItems'
$managercombo.AutoCompleteMode = 'Append'
$ManagerCombo.SelectedIndex =-1

#endregion

#region Event Loop

function Main{
	[System.Windows.Forms.Application]::EnableVisualStyles()
	[System.Windows.Forms.Application]::Run($form1)
}

#endregion

#endregion

#region Event Handlers


function LogonnameupntextboxTextChanged( $object ){

}

function LogonNameTextboxTextChanged( $object ){
    $script:logonname = $LogonNameTextbox.Text
}

function InitialTextBoxChanged( $object ){

}

function get-password
{
	param(
		[string]$length = "15"
	)
	    
	$Password = New-Object -TypeName PSObject
	$Password | Add-Member -MemberType ScriptProperty -Name "Password" -Value { `
		( "!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | `
		Sort-Object { Get-Random } )[0..$length] -join ''
	}
	$script:Pass = $Password.Password
	$script:Pass
}

function write-Log {
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
        write-Log -messages Value -level Value
        Describe what this call does
  
        .NOTES
        Place additional notes here.
  
        .LINK
        URLs to related sites
        The first link is opened by Get-Help -Online write-Log
  
        .INPUTS
        List of input types that are accepted by this function.
  
        .OUTPUTS
        List of output types produced by this function.
    #>
  
    param(
      [Parameter(Mandatory = $true,HelpMessage='Add help message for user')][string[]] $messages,
      [ValidateSet('INFO','WARN','ERROR')]
      [string] $level = 'INFO'
    )
  
    # Create timestamp
    $timestamp = (Get-Date).toString('yyyy/MM/dd HH:mm:ss')
  
    # Append content to log file
    foreach($message in $messages){
        Add-Content -Path $logFile -Value ('{0} [{1}] [{2}] - {3}' -f $timestamp, $level,$env:COMPUTERNAME, $message)
        Start-Sleep -Seconds 2
    }
}
  
function Get-status{
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
        [parameter(Mandatory=$true,HelpMessage='Add help message for user')]
        [string]$message
    )
    if( $? -eq $true ) {
        $messagefinal=$message+'- success'
        write-log -level INFO -message $messagefinal
      } 
    else {
        $messagefinal=$message+'- failed'
        write-log -level ERROR -message $messagefinal
    }
}

function Send-email {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true,HelpMessage='Add help message for user')]
        [string]
        $emailbody,
        [Parameter(Mandatory = $true,HelpMessage='Add help message for user')]
        [string[]]
        $targetusers,
        [Parameter(Mandatory=$false)]
        [string]$subject="User Account Management"
    )
        
    begin {
        [Net.ServicePointManager]::SecurityProtocol =[Net.SecurityProtocolType]::Tls12
        write-Log -messages "Initializing Email sending process"            
    }    
    process {        
        write-Log -messages "Email process initialized"
        try {
            foreach($targetuser in $targetusers){        
                $smtp = New-Object System.Net.Mail.SmtpClient
                $to = New-Object System.Net.Mail.MailAddress($email)
                $from = New-Object System.Net.Mail.MailAddress("itocblrusermgmt@hpe.com")
                #$attachment="C:\Users\yyy1g92\Desktop\Sreeni\newlog.txt"
                $msg = New-Object System.Net.Mail.MailMessage($from, $to)
                $msg.subject = $subject
                $msg.body = $emailbody
                $msg.IsBodyHtml="True"
                #$msg.Attachments.Add($attachment)
                $smtp.host = "smtp1.hpe.com"
                $SMTP.Port = 25
                $smtp.send($msg)
                Get-status -message "Email sent to $($targetuser."Display name")"  
            }
        }
        catch {
            write-log -message ('Error Happened while sending email :{0} : {1}' -f $error[0].InvocationInfo.Line, $error[0].Exception.Message)
        }
        finally {
            $error.Clear()
        } 
    }
        end {
            write-Log -messages "Email Sending process completed"
        }
}

function DomainPretextboxTextChanged( $object ){
    
    $script:domain = $domainPretextbox.Text
}

function EmailTextBoxTextChanged( $object ){
    $script:email = $EmailTextBox.Text
}

function Managercomboclick( $object ){
    
}

function ManagerComboSelectedIndexChanged( $object ){
    $script:manager = $ManagerCombo.Selecteditem.ToString()
}

function FullNameTextboxTextChanged( $object ){
    $script:fullname = $FullNameTextbox.Text
}

function LastNameTextboxTextChanged( $object ){
    $script:lastname = $LastNameTextbox.Text
}

function FirstnameTextboxTextChanged( $object ){
    $script:Firstname = $FirstnameTextbox.text
}

function Form1Load( $object ){

}

function resultsclick( $object ){

}

function LogonPretextboxTextChanged( $object ){

}

function createbuttonClick( $object ){
    $ErrorActionPreference="stop"
    
    try {
        if(!$firstname -or !$Fullname -or !$Manager -or !$domain -or !$logonname -or !$Email ){
            throw
        }
        
        $pass=(get-password -length 20)
        $password=(ConvertTo-SecureString -AsPlainText -String $pass -Force)

        $scriptuser=@{
            'Name'=($firstname + " " + $Lastname)
            'Manager'=$Manager
            'ChangePasswordAtlogon'=$true
            'Userprincipalname'=($logonname+"@"+$env:USERDNSDOMAIN)
            'EmailAddress'=$email
            'Surname'=$Lastname
            'GivenName'=$firstname
            'Displayname'=$Fullname
            'Enabled'=$true
            'Path'="OU=SME Users,DC=hpe-cscitoc,DC=net"
            'AccountPassword'=$password
            'SamAccountname'=$domain
            'confirm'=$false
        }

        if($logonname -ne $domain){
            throw
        }

        New-ADUser @scriptuser

        $resultslabel.ForeColor="Green"
        $resultslabel.Text="Account successfully created, password copied to clipboard !!"
        $pass | Set-Clipboard
        $user=Get-ADUser -identity $logonname
        Add-ADGroupMember -identity $group -members $user
        Start-Sleep -Seconds 22
        $Form1.Close()
    
    }
    catch {
            
            if(([string]::IsNullOrEmpty($firstname))) { 
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="Please Enter first name of the User"
            
            }
            elseif(([string]::IsNullOrEmpty($lastname))) { 
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="Please Enter last name of the User"
            }
            
            elseif(([string]::IsNullOrEmpty($Fullname))) { 
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="Please Enter display name of the User"
                
            }

            elseif(([string]::IsNullOrEmpty($logonname))) { 
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="Please Enter logon name of the User"
                
            }

            elseif(([string]::IsNullOrEmpty($Manager))) { 
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="Please select manager from the drop-down menu"
            }

            elseif(([string]::IsNullOrEmpty($email))) { 
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="Please Enter Email of the User"
            }
            
            elseif(([string]::IsNullOrEmpty($domain))) {
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="Please Enter logon name (pre-windows 2000) of the User"
            }

            elseif(Get-ADUser -Filter * -Properties userprincipalname | Where-Object `
            {$_.userprincipalname -eq ($logonname+"@"+$env:userdnsdomain)} -ErrorAction SilentlyContinue){
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="User with same userprincipalname already exist"
            }
            elseif(Get-ADUser -filter * -Properties samaccountname | Where-Object `
            {$_.samaccountname -eq $domain} -ErrorAction SilentlyContinue){
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="User with same samaccountname already exist"
            }
            elseif($logonname -ne $domain){
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text="Logon Name and pre-windows logon name should be same."
            }
            
            else{
                $resultslabel.font="Arial Rounded MT"
                $resultslabel.ForeColor="Red"
                $resultslabel.Text=$Error[0].Exception.Message
            }
    }
    finally{
        $erroractionpreference="continue"
    }
}

Main # This call must remain below all other event functions


#endregion
#region Script Settings
#<ScriptSettings xmlns="http://tempuri.org/ScriptSettings.xsd">
#  <ScriptPackager>
#    <process>powershell.exe</process>
#    <arguments />
#    <extractdir>%TEMP%</extractdir>
#    <files />
#    <usedefaulticon>true</usedefaulticon>
#    <showinsystray>false</showinsystray>
#    <altcreds>false</altcreds>
#    <efs>true</efs>
#    <ntfs>true</ntfs>
#    <local>false</local>
#    <abortonfail>true</abortonfail>
#    <product />
#    <version>1.0.0.1</version>
#    <versionstring />
#    <comments />
#    <company />
#    <includeinterpreter>false</includeinterpreter>
#    <forcecomregistration>false</forcecomregistration>
#    <consolemode>false</consolemode>
#    <EnableChangelog>false</EnableChangelog>
#    <AutoBackup>false</AutoBackup>
#    <snapinforce>false</snapinforce>
#    <snapinshowprogress>false</snapinshowprogress>
#    <snapinautoadd>2</snapinautoadd>
#    <snapinpermanentpath />
#    <cpumode>1</cpumode>
#    <hidepsconsole>false</hidepsconsole>
#  </ScriptPackager>
#</ScriptSettings>
#endregion

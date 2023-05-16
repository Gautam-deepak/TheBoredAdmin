##############################################################################################################################
#   Author :- Deepak Gautam                                                                                                  #
#   Email :- deepak.gautam@hpe.com                                                                                           #
#   Date :- 01-Dec-2022                                                                                                      #
#   Description :- Tool is automate collection of information from multiple iLOIps                                           #
##############################################################################################################################

<#PSScriptInfo
    .VERSION 1.0.0
    .GUID 96182379-a9c2-4803-aa9f-689cc524619d
    .AUTHOR deepak.gautam@hpe.com
    .COMPANYNAME MIT
    .COPYRIGHT MIT. All rights reserved.
    .TAGS Tag1 Tag2 Tag3
    .LICENSEURI https://contoso.com/License
    .PROJECTURI https://contoso.com/
    .ICONURI https://contoso.com/Icon
    .EXTERNALMODULEDEPENDENCIES ff,bb
    .REQUIREDSCRIPTS Start-WFContosoServer,Stop-ContosoServerScript
    .EXTERNALSCRIPTDEPENDENCIES Stop-ContosoServerScript
    .RELEASENOTES
    Contoso script now supports the following features:
    Feature 1
    Feature 2
    Feature 3
    Feature 4
    Feature 5
    .PRIVATEDATA
#>

#Requires -Module @{ModuleName = 'HPEilocmdlets'; ModuleVersion = '3.3.0.0'}
#Requires -version 5.1

<#
    .DESCRIPTION
    Tool is automate collection of information from multiple iLOIps
#>

<#
    Features,improvements and current status of bugs in the tool :-
    1.  Feature : csv entry validation per item - Added
    2.  Feature : IP validation - Added
    3.  Bug : licenseinfo being used , tool crashes - Fixed
    4.  Feature : file validation in text and csv file - csv Added, text Added
    5.  Bug : blank tool should have no action -fixed
    6.  Bug : everything should be under try catch, fields to be captured in catch - fixed
    7.  Feature : Parallel processing of AHS logs - Added
    8.  Bug : health and uptime - first correct value of $issue is blank in outputbox if connection goes through -Fixed
    9.  Bug : AHS - errors out sometimes key already exist for connection - Fixed (removed parallel)
    10. INFO : Added IML logs button
    11. INFO : Added OAinfo Button with message not suppported on ilo5 - Removed during Discussion
    12. INFO - Upgrade firmware, Backup/restore and Set-user button
    13. Feature : Blank text,CSV,bak and bin file detection. - Added
    14. Feature : Add logging and auditing of the tool - Added
    15. INFO : Updated logic for all subforms upgrade firmware, backup/restore and set user button
    16. Feature : Limit username and password textboxes to 24 and 30 char respectively. - Added
    17. Feature : Limit bin and backup field to take bin and bak file only. - Added
    18. Feature : Limit multiple duplicate entries in text, manual and in csv file to avoid brute force or dictionary attacks. - Added
    19. Feature : Enable Hashing of the script to avoid temperment with it - pending
    20. Feature : Encryption of the script - pending
    21. Feature : Add secure channel if available and continue if not - exception handling for the error
                  [IP] : The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel - Added
    22. INFO : HpeiloCmdlets must be installed system wide not per user - Not Required anymore
                Install-module -Name Hpeilocmdlets -scope allusers
    23. Bug : Add-hpeilouser recreates the user if already exist instead it should error out saying "User already exist" - Fixed
    24. Bug : Set-hpeilouser -newpassword show success even for the user which doesn't exist - Fixed
    25. INFO: Updated all logic of set user, backup/restore and upgrade firmware buttons.
    26. Feature : Microsoft recommended best code practices are followed using PSScriptAnalyzer. - Added
    27. Feature : Limit username and password fields in csv file to 24 and 30 char respectively. - Added
    28. Feature : CSV file only allows iLOIP,Username and password columns only to avoid unwanted injection of data in memory. -Added
    29. Feature : Allow secure and unsecure connection both - Added
    30. INFO : Removed IML and health powershell commands and included script.xml
    31. INFO : Updated script with PS version 5.1 (needed .net 4.7.2 version to be installed)
    32. INFO : Removed script.xml in IML/HEALTH and added powershell commands back
#>

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
$Form1.ClientSize = New-Object System.Drawing.Size(683, 458)
$Form1.Text = "iLO Info Tool"
#~~< ProgressBar >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ProgressBar = New-Object System.Windows.Forms.ProgressBar
$ProgressBar.AccessibleDescription = "Loading..."
$ProgressBar.Location = New-Object System.Drawing.Point(27, 423)
$ProgressBar.Size = New-Object System.Drawing.Size(636, 23)
$ProgressBar.Style = [System.Windows.Forms.ProgressBarStyle]::Continuous
$ProgressBar.TabIndex = ""
$ProgressBar.Text = ""
$ProgressBar.add_Click({ProgressBarClick($ProgressBar)})
#~~< resetbutton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$reset = New-Object System.Windows.Forms.Button
$reset.Location = New-Object System.Drawing.Point(553, 168)
$reset.Size = New-Object System.Drawing.Size(110, 30)
$reset.TabIndex = 16
$reset.Text = "Clear Screen"
$reset.UseVisualStyleBackColor = $true
$reset.add_Click({resetbuttonClick($reset)})
#~~< Upgrade >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Upgrade = New-Object System.Windows.Forms.Button
$Upgrade.Location = New-Object System.Drawing.Point(553, 132)
$Upgrade.Size = New-Object System.Drawing.Size(110, 30)
$Upgrade.TabIndex = 15
$Upgrade.Text = "Upgrade"
$Upgrade.UseVisualStyleBackColor = $true
$Upgrade.add_Click({UpgradeClick($Upgrade)})
#~~< Set_user >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Set_user = New-Object System.Windows.Forms.Button
$Set_user.Location = New-Object System.Drawing.Point(553, 96)
$Set_user.Size = New-Object System.Drawing.Size(110, 30)
$Set_user.TabIndex = 14
$Set_user.Text = "Set User"
$Set_user.UseVisualStyleBackColor = $true
$Set_user.add_Click({Set_userClick($Set_user)})
#~~< OA >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$BR = New-Object System.Windows.Forms.Button
$BR.Location = New-Object System.Drawing.Point(553, 60)
$BR.Size = New-Object System.Drawing.Size(110, 30)
$BR.TabIndex = 13
$BR.Text = "Backup/Restore"
$BR.UseVisualStyleBackColor = $true
$BR.add_Click({BRClick($BR)})
#~~< Button5 >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$HealthButton = New-Object System.Windows.Forms.Button
$HealthButton.Location = New-Object System.Drawing.Point(553, 24)
$HealthButton.Size = New-Object System.Drawing.Size(110, 30)
$HealthButton.TabIndex = 12
$HealthButton.Text = "Health"
$HealthButton.UseVisualStyleBackColor = $true
$HealthButton.add_Click({HealthButtonClick($HealthButton)})
#~~< HardwareButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$IMLButton = New-Object System.Windows.Forms.Button
$IMLButton.Location = New-Object System.Drawing.Point(437, 168)
$IMLButton.Size = New-Object System.Drawing.Size(110, 30)
$IMLButton.TabIndex = 11
$IMLButton.Text = "IML Logs"
$IMLButton.UseVisualStyleBackColor = $true
$IMLButton.add_Click({IMLButtonClick($IMLButton)})
#~~< FirmwareButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$FirmwareButton = New-Object System.Windows.Forms.Button
$FirmwareButton.Location = New-Object System.Drawing.Point(437, 132)
$FirmwareButton.Size = New-Object System.Drawing.Size(110, 30)
$FirmwareButton.TabIndex = 10
$FirmwareButton.Text = "Inventory"
$FirmwareButton.UseVisualStyleBackColor = $true
$FirmwareButton.add_Click({FirmwareButtonClick($FirmwareButton)})
#~~< UptimeButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$UptimeButton = New-Object System.Windows.Forms.Button
$UptimeButton.Location = New-Object System.Drawing.Point(437, 96)
$UptimeButton.Size = New-Object System.Drawing.Size(110, 30)
$UptimeButton.TabIndex = 9
$UptimeButton.Text = "Uptime"
$UptimeButton.UseVisualStyleBackColor = $true
$UptimeButton.add_Click({UptimeButtonClick($UptimeButton)})
#~~< AHSButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$AHSButton = New-Object System.Windows.Forms.Button
$AHSButton.Location = New-Object System.Drawing.Point(437, 60)
$AHSButton.Size = New-Object System.Drawing.Size(110, 30)
$AHSButton.TabIndex = 8
$AHSButton.Text = "AHS"
$AHSButton.UseVisualStyleBackColor = $true
$AHSButton.add_Click({AHSButtonClick($AHSButton)})
#~~< PasswordFileLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PasswordFileLabel = New-Object System.Windows.Forms.Label
$PasswordFileLabel.Location = New-Object System.Drawing.Point(27, 159)
$PasswordFileLabel.Size = New-Object System.Drawing.Size(87, 17)
$PasswordFileLabel.TabIndex = ""
$PasswordFileLabel.Text = "CSV File"
$PasswordFileLabel.add_Click({PasswordFileLabelClick($PasswordFileLabel)})
#~~< PasswordfileText >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PasswordfileText = New-Object System.Windows.Forms.TextBox
$PasswordfileText.Location = New-Object System.Drawing.Point(120, 159)
$PasswordfileText.Size = New-Object System.Drawing.Size(291, 20)
$PasswordfileText.TabIndex = 5
$PasswordfileText.Text = ""
$PasswordfileText.autocompletemode='SuggestAppend'
$PasswordfileText.autocompletesource='FileSystem'
$PasswordfileText.add_TextChanged({PasswordfileTextTextChanged($PasswordfileText)})
#~~< FilePathTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$FilePathTextBox = New-Object System.Windows.Forms.TextBox
$FilePathTextBox.Location = New-Object System.Drawing.Point(120, 24)
$FilePathTextBox.Size = New-Object System.Drawing.Size(291, 20)
$FilePathTextBox.TabIndex = 0
$FilePathTextBox.Text = ""
$FilePathTextBox.autocompletemode='SuggestAppend'
$FilePathTextBox.autocompletesource='FileSystem'
$FilePathTextBox.add_TextChanged({FilePathTextBoxTextChanged($FilePathTextBox)})
#~~< FileLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$FileLabel = New-Object System.Windows.Forms.Label
$FileLabel.Location = New-Object System.Drawing.Point(27, 27)
$FileLabel.Size = New-Object System.Drawing.Size(87, 17)
$FileLabel.TabIndex = ""
$FileLabel.Text = "Text File"
$FileLabel.add_Click({FileLabelClick($FileLabel)})
#~~< iLOTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$iLOTextbox = New-Object System.Windows.Forms.TextBox
$iLOTextbox.Location = New-Object System.Drawing.Point(120, 53)
$iLOTextbox.Size = New-Object System.Drawing.Size(291, 20)
$iLOTextbox.TabIndex = 1
$iLOTextbox.Text = ""
$iLOTextbox.add_TextChanged({iLOTextChanged($iLOTextbox)})
#~~< iLOLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$iLOLabel = New-Object System.Windows.Forms.Label
$iLOLabel.Location = New-Object System.Drawing.Point(27, 56)
$iLOLabel.Size = New-Object System.Drawing.Size(87, 17)
$iLOLabel.TabIndex = ""
$iLOLabel.Text = "iLO IPs"
$iLOLabel.add_Click({ILOLabelClick($iLOLabel)})
#~~< OutputLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$OutputLabel = New-Object System.Windows.Forms.Label
$OutputLabel.Location = New-Object System.Drawing.Point(27, 187)
$OutputLabel.Size = New-Object System.Drawing.Size(87, 19)
$OutputLabel.TabIndex = ""
$OutputLabel.Text = "Output"
$OutputLabel.add_Click({OutputLabelClick($OutputLabel)})
#~~< OutputTextBox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$OutputTextBox = New-Object System.Windows.Forms.RichTextBox
$OutputTextBox.Location = New-Object System.Drawing.Point(27, 209)
$OutputTextBox.Size = New-Object System.Drawing.Size(636, 216)
$OutputTextBox.TabIndex = 7
$OutputTextBox.Text = ""
$OutputTextBox.ReadOnly=$true
$OutputTextBox.add_TextChanged({OutputTextChanged($OutputTextBox)})
#~~< PasswordLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PasswordLabel = New-Object System.Windows.Forms.Label
$PasswordLabel.Location = New-Object System.Drawing.Point(27, 124)
$PasswordLabel.Size = New-Object System.Drawing.Size(87, 20)
$PasswordLabel.TabIndex = ""
$PasswordLabel.Text = "Password"
$PasswordLabel.add_Click({PasswordLabelClick($PasswordLabel)})
#~~< UsernameLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$UsernameLabel = New-Object System.Windows.Forms.Label
$UsernameLabel.Location = New-Object System.Drawing.Point(27, 92)
$UsernameLabel.Size = New-Object System.Drawing.Size(75, 20)
$UsernameLabel.TabIndex = ""
$UsernameLabel.Text = "Username"
$UsernameLabel.add_Click({UsernameLabelClick($UsernameLabel)})
#~~< PasswordTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$PasswordTextbox = New-Object System.Windows.Forms.TextBox
$PasswordTextbox.Location = New-Object System.Drawing.Point(120, 124)
$PasswordTextbox.Size = New-Object System.Drawing.Size(176, 20)
$PasswordTextbox.TabIndex = 3
$PasswordTextbox.Text = ""
$PasswordTextbox.MaxLength=30
$PasswordTextbox.UseSystemPasswordChar=$true
$PasswordTextbox.add_TextChanged({PasswordTextChanged($PasswordTextbox)})
#~~< ShowPassword >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$ShowPassword = New-Object System.Windows.Forms.CheckBox
$ShowPassword.Location = New-Object System.Drawing.Point(302, 124)
$ShowPassword.Size = New-Object System.Drawing.Size(109, 20)
$ShowPassword.TabIndex = 4
$ShowPassword.Text = "Show Password"
$ShowPassword.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
$ShowPassword.UseVisualStyleBackColor = $true
$ShowPassword.add_CheckedChanged({ShowPasswordCheckedChanged($ShowPassword)})
#~~< UsernameTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$UsernameTextbox = New-Object System.Windows.Forms.TextBox
$UsernameTextbox.Location = New-Object System.Drawing.Point(120, 89)
$UsernameTextbox.Size = New-Object System.Drawing.Size(291, 20)
$UsernameTextbox.TabIndex = 2
$UsernameTextbox.Text = ""
$UsernameTextbox.MaxLength=24
$UsernameTextbox.add_TextChanged({UsernameTextChanged($UsernameTextbox)})
#~~< Licensebutton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
$Licensebutton = New-Object System.Windows.Forms.Button
$Licensebutton.Location = New-Object System.Drawing.Point(437, 24)
$Licensebutton.Size = New-Object System.Drawing.Size(110, 30)
$Licensebutton.TabIndex = 6
$Licensebutton.Text = "License"
$Licensebutton.UseVisualStyleBackColor = $true
$Licensebutton.add_Click({LicenseButtonClick($Licensebutton)})

$Form1.Controls.Add($ShowPassword)
$Form1.Controls.Add($ProgressBar)
$Form1.Controls.Add($reset)
$Form1.Controls.Add($Upgrade)
$Form1.Controls.Add($Set_user)
$Form1.Controls.Add($BR)
$Form1.Controls.Add($HealthButton)
$Form1.Controls.Add($IMLButton)
$Form1.Controls.Add($FirmwareButton)
$Form1.Controls.Add($UptimeButton)
$Form1.Controls.Add($AHSButton)
$Form1.Controls.Add($PasswordFileLabel)
$Form1.Controls.Add($PasswordfileText)
$Form1.Controls.Add($FilePathTextBox)
$Form1.Controls.Add($FileLabel)
$Form1.Controls.Add($iLOTextbox)
$Form1.Controls.Add($iLOLabel)
$Form1.Controls.Add($OutputLabel)
$Form1.Controls.Add($OutputTextBox)
$Form1.Controls.Add($PasswordLabel)
$Form1.Controls.Add($UsernameLabel)
$Form1.Controls.Add($PasswordTextbox)
$Form1.Controls.Add($UsernameTextbox)
$Form1.Controls.Add($Licensebutton)
$Form1.add_Load({Form1Load($Form1)})

#endregion

#region Custom Code
    try {
        if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {
            throw
        }
    }
    catch {
        $Licensebutton.Enabled=$false
        $Ahsbutton.Enabled=$false
        $imlbutton.Enabled=$false
        $healthbutton.Enabled=$false
        $Set_user.Enabled=$false
        $uptimebutton.Enabled=$false
        $firmwarebutton.Enabled=$false
        $Upgrade.Enabled=$false
        $BR.Enabled=$false
        $reset.Enabled=$false
        $OutputTextBox.ForeColor="Red"
        $OutputTextBox.Text="You must run the tool as administrator."
    }
    Import-Module -Name Hpeilocmdlets
    If(!(Test-path -Path $env:HOMEDRIVE\temp)){$null = New-Item -Name temp -Path $env:HOMEDRIVE\ -ItemType Directory}
    If(!(Test-path -Path $env:HOMEDRIVE\temp\iLOInfo)){$null = New-Item -Name iLOInfo -Path $env:HOMEDRIVE\temp -ItemType Directory}
    $script:headers="iloip","username","password"
    $date=Get-Date -Format 'MM-dd-yyyy'
    New-Item -Type Directory -Path ([Environment]::GetFolderPath("Desktop")+"\"+"$($date)_iLO") -Force | Out-Null
    $script:scriptdirectory="C:\temp\iLOInfo\"
    $logFile = $scriptdirectory+"iLOInfo.log"
    $script:filedirectory=([Environment]::GetFolderPath("Desktop")+"\"+"$($date)_iLO")
    $script:desktop=([Environment]::GetFolderPath("Desktop"))
    $script:licensepath=$filedirectory+"\"+"licenseInfo.csv"
    $script:healthpath=$filedirectory+"\"+"HealthInfo.csv"
    $script:uptimepath=$filedirectory+"\"+"UptimeInfo.csv"
    $script:Firmwarepath=$filedirectory+"\"+"FirmwareInfo.csv"
    $script:Ahspath=$filedirectory+"\"+"AHSInfo.csv"
    $script:imlpath=$filedirectory+"\"+"ImlInfo.csv"
    $script:BRpath=$filedirectory+"\"+"BackupRestoreInfo.csv"
    $script:Upgradepath=$filedirectory+"\"+"UpgradeInfo.csv"
    $script:setuserpath=$filedirectory+"\"+"SetUserInfo.csv"

#endregion

#region Event Loop

function Main{
	[System.Windows.Forms.Application]::EnableVisualStyles()
	[System.Windows.Forms.Application]::Run($Form1)
}

#endregion

#endregion

#region Event Handlers

Function Write-myLog {
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
          [ValidateSet('INFO','WARN','ERROR')]
          [string] $level = 'INFO'
      )

      # Create timestamp
      $timestamp = (Get-Date).toString('yyyy/MM/dd HH:mm:ss')

      # Append content to log file
      foreach($message in $messages){
        Add-Content -Path $logFile -Value ('{0} [{1}] [{2}] - {3}' -f $timestamp, $level,$($env:USERDNSDOMAIN+"\"+$env:USERNAME),$message)
        Start-Sleep -Seconds 2
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

function resetbuttonClick( $object ){
    Write-myLog -level INFO -messages "User clicked on clear screen button"
    $FilePathTextBox.Text=""
    $iLOTextbox.Text=""
    $UsernameTextbox.Text=""
    $PasswordTextbox.Text=""
    $OutputTextBox.text=""
    $ProgressBar.value=0
    $PasswordfileText.text=""
    $ShowPassword.Checked=$false

    if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
    if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
    if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
    if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
}

function UpgradeClick( $object ){

    $Form2 = New-Object System.Windows.Forms.Form
    $Form2.ClientSize = New-Object System.Drawing.Size(530, 92)
    $Form2.Text = "Upgrade Firmware"
    #~~< setbinfilepathbutton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $setbinfilepathbutton = New-Object System.Windows.Forms.Button
    $setbinfilepathbutton.Location = New-Object System.Drawing.Point(450, 9)
    $setbinfilepathbutton.Size = New-Object System.Drawing.Size(68, 20)
    $setbinfilepathbutton.TabIndex = 3
    $setbinfilepathbutton.Text = "Set"
    $setbinfilepathbutton.UseVisualStyleBackColor = $true
    $setbinfilepathbutton.add_Click({SetButtonClick($setbinfilepathbutton)})
    #~~< resultbinlabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $resultbinlabel = New-Object System.Windows.Forms.Label
    $resultbinlabel.Location = New-Object System.Drawing.Point(13, 49)
    $resultbinlabel.Size = New-Object System.Drawing.Size(491, 23)
    $resultbinlabel.TabIndex = 2
    $resultbinlabel.Text = ""
    $resultbinlabel.add_Click({ResultbinlabelClick($resultbinlabel)})
    #~~< binfilepathtextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $binfilepathtextbox = New-Object System.Windows.Forms.TextBox
    $binfilepathtextbox.Location = New-Object System.Drawing.Point(89, 9)
    $binfilepathtextbox.Size = New-Object System.Drawing.Size(355, 20)
    $binfilepathtextbox.TabIndex = 1
    $binfilepathtextbox.Text = ""
    $binfilepathtextbox.AutoCompleteMode='SuggestAppend'
    $binfilepathtextbox.AutoCompleteSource='FileSystem'
    $binfilepathtextbox.add_TextChanged({BinfilepathtextboxTextChanged($binfilepathtextbox)})
    #~~< BinPathlabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $BinPathlabel = New-Object System.Windows.Forms.Label
    $BinPathlabel.ImageAlign = [System.Drawing.ContentAlignment]::BottomCenter
    $BinPathlabel.Location = New-Object System.Drawing.Point(13, 9)
    $BinPathlabel.Size = New-Object System.Drawing.Size(70, 20)
    $BinPathlabel.TabIndex = 0
    $BinPathlabel.Text = "Bin File Path"
    $BinPathlabel.add_Click({BinPathlabelClick($BinPathlabel)})
    $Form2.Controls.Add($setbinfilepathbutton)
    $Form2.Controls.Add($resultbinlabel)
    $Form2.Controls.Add($binfilepathtextbox)
    $Form2.Controls.Add($BinPathlabel)


    function BinPathlabelClick( $object ){

    }

    function ResultbinlabelClick( $object ){

    }
    function BinfilepathtextboxTextChanged( $object ){
        $script:binfilepath=$binfilepathtextbox.Text
    }
    function SetButtonClick( $object ){

        $script:upgrade_operation=""
        $resultbinlabel.ForeColor="Black"
        if([string]::IsNullOrEmpty($binfilepathtextbox.Text)){
            $resultbinlabel.ForeColor="Red"
            $resultbinlabel.Text="Please set the bin file path"
        }
        else{
            $bin_validation_msg=test-bin -path $binfilepathtextbox.Text
            if([string]::IsNullOrEmpty($bin_validation_msg)){
                $resultbinlabel.ForeColor="Black"
                $resultbinlabel.Text="Bin file path : $($binfilepath)"
                write-mylog -level INFO -messages "Bin file path : $($binfilepath)"

                $script:upgraderesult = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to continue, this will upgrade firmware on multiple iLO?", "Confirmation", `
                [System.Windows.Forms.MessageBoxButtons]::OKCancel)

                if ($upgraderesult -eq "OK") {
                    $script:upgrade_operation="Upgrade"
                    $form2.Close()
                    return $true
                }
                else {
                    $script:upgrade_operation=""
                    $form2.Close()
                    return $false
                }
            }
            else{
                $resultbinlabel.ForeColor="Red"
                $resultbinlabel.Text=$bin_validation_msg
            }
        }
    }
    Write-myLog -level INFO -messages "User clicked on upgrade button"
    $script:upgrade_operation=""
    $ErrorActionPreference="stop"
    $outputtextbox.ForeColor="Black"
    $outputtextbox.text="Validating information..."
    Start-Sleep -Seconds 1
    try {
        if((Test-FileLock -Path $UpgradePath)){
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $outputtextbox.text="Please wait..."
            Start-Sleep -Seconds 1
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and (![string]::IsNullOrEmpty($PasswordfileText.Text))){

            try {
                if((![string]::IsNullOrEmpty($UsernameTextbox.Text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.Text))){
                    $outputtextbox.text="Please wait..."
                    Start-Sleep -Seconds 1
                    throw
                }
                $messages=test-csv -path $PasswordfileText.Text
                if(!($messages)){
                    $outputtextbox.text="CSV is validated.."
                    Write-myLog -level INFO -messages "CSV validated"
                    Write-myLog -level INFO -messages "CSV file path : $($PasswordfileText.Text)"
                    Start-Sleep 2
                    $csvfile=import-csv -path $passwordfiletext.text  | Sort-Object iloIP -Unique
                    $ProgressBar.Maximum=$csvfile.count
                    $ProgressBar.Value=0
                    $ProgressBar.Step=1
                    $OutputTextBox.Text="Please wait........."
                    try {
                        $form2.showdialog()
                        $OutputTextBox.Text="Validating the firmware upgrade, please do not close the tool or clear the screen........."
                        Write-myLog -level INFO -messages "Validating the firmware upgrade, please do not close the tool or clear the screen....."
                        if($upgrade_operation -eq "Upgrade"){
                            $csvresults=foreach($item in $csvfile){
                                try {
                                    $ErrorActionPreference="stop"
                                    $connection=Connect-HPEiLO $Item.iloip -Username $item.username -Password $item.password `
                                    -WarningAction Ignore
                                    Update-HPEiLOFirmware -Connection $connection -Location $binfilepath `
                                    -UploadTimeout 700 -confirm:$false -warningaction ignore
                                    Write-myLog -messages "Connection to $($item.iloip) is secure"
                                    $Status="Success"
                                    $Issue="No Error"
                                }
                                catch {
                                    if($Error[0].Exception.Message -match  `
                                    "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                    -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                        try {
                                            $ErrorActionPreference="stop"
                                            $connection=Connect-HPEiLO $Item.iloip -Username $item.username -Password $item.password `
                                            -DisableCertificateAuthentication -WarningAction Ignore
                                            Update-HPEiLOFirmware -Connection $connection -Location $binfilepath `
                                            -UploadTimeout 700 -confirm:$false -warningaction ignore
                                            Write-myLog -messages "Connection to $($item.iloip) is unsecure"
                                            $Status="Success"
                                            $Issue="No Error"
                                        }
                                        catch {
                                            $status="Failure"
                                            $Issue="$($Error[0].Exception.Message)"
                                        }
                                    }
                                    else{
                                        $status="Failure"
                                        $Issue="$($Error[0].Exception.Message)"
                                    }
                                }
                                [PSCustomObject]@{
                                    'iLO IP'=$Item.iloip
                                    'Firmware Update Status'=$Status
                                    'Error'=$Issue
                                }
                            }
                        }
                        else{
                            throw
                        }
                        $outputtextbox.ForeColor="Green"
                        $OutputTextBox.Text="Please check the UpgradeINFO file to check the status of Upgrade firmware logs..."
                        Write-myLog -level INFO -messages "UpgradeINFO file generatated..."
                    }
                    catch {
                        $outputtextbox.ForeColor="Red"
                        $outputtextbox.Text="User cancelled the process"
                        Write-myLog -level ERROR -messages "User cancelled the process"
                    }
                }
                else {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="CSV validation failed..."
                    Write-myLog -level ERROR -messages "CSV validation failed"
                    Write-myLog -level ERROR -messages $messages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $messages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
            catch {
                $ProgressBar.Value=0
                $outputtextbox.ForeColor="Red"
                $outputtextbox.text="You cannot define username or password with CSV file"
                Write-myLog -level ERROR -messages "User defined username or password with CSV file"
                Start-Sleep -Seconds 1
            }
        }
        else{
            try {

                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }
                if((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $outputtextbox.ForeColor="Black"
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((![string]::IsNullOrEmpty($FilePathTextBox.text))){
                    $ipvalidationmessages=test-iloIP -path $FilePathTextBox.Text
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$fileiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined text file with successful validation"
                    Write-myLog -level INFO -messages "Text file path : $($FilePathTextBox.Text)"
                }
                elseif(![string]::IsNullOrEmpty($iLOTextbox.text)){
                    $ipvalidationmessages=test-iloIpstring -IPs $textiloips
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$textiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined manual iLO IPs with successful validation"
                }
                $ProgressBar.Maximum=$iloIPs.count
                $ProgressBar.Value=0
                $ProgressBar.Step=1
                $outputtextbox.ForeColor="Black"
                $OutputTextBox.Text="Please wait........."
                try {
                    $form2.showdialog()
                    $OutputTextBox.Text="Validating the firmware upgrade, please do not close the tool or clear the screen........."
                    Write-myLog -level INFO -messages "Validating the firmware upgrade, please do not close the tool or clear the screen.."
                    if($upgrade_operation -eq "Upgrade"){
                        $csvresults=foreach($iloip in $iloIPs) {
                            try {
                                $ErrorActionPreference="stop"
                                $connection=Connect-HPEiLO $iloip -Username $user -Password $password `
                                -WarningAction Ignore
                                Update-HPEiLOFirmware -Connection $connection -Location $binfilepath `
                                -UploadTimeout 700 -confirm:$false -warningaction ignore
                                Write-myLog -messages "Connection to $($iloip) is secure"
                                $Status="Success"
                                $Issue="No Error"
                            }
                            catch {
                                if($Error[0].Exception.Message -match  `
                                    "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                    -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                    try {
                                        $ErrorActionPreference="stop"
                                        $connection=Connect-HPEiLO $iloip -Username $user -Password $password `
                                        -DisableCertificateAuthentication -WarningAction Ignore
                                        Update-HPEiLOFirmware -Connection $connection -Location $binfilepath `
                                        -UploadTimeout 700 -confirm:$false -warningaction ignore
                                        Write-myLog -messages "Connection to $($iloip) is unsecure"
                                        $Status="Success"
                                        $Issue="No Error"
                                    }
                                    catch {
                                        $status="Failure"
                                        $Issue="$($Error[0].Exception.Message)"
                                    }
                                }
                                else{
                                    $status="Failure"
                                    $Issue="$($Error[0].Exception.Message)"
                                }
                            }

                            [PSCustomObject]@{
                                'iLO IP'=$iloip
                                'Firmware Upgrade Status'=$Status
                                'Error'=$Issue
                            }
                        }
                    }
                    else{
                        throw
                    }
                    $outputtextbox.ForeColor="Green"
                    $OutputTextBox.Text="Please check the UpgradeINFO file to check the status of Upgrade firmware logs..."
                    Write-myLog -level INFO -messages "UpgradeInfo file generated"
                }
                catch {
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.Text="User cancelled the process"
                    Write-myLog -level ERROR -messages "User cancelled the process"
                }
            }
            catch {
                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User defined multiple fields"
                    $Error.Clear()
                }

                elseif((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User didn't define any of the field along with username and password"
                    $Error.Clear()
                }
                elseif((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($ilotextbox.text))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs to continue.."
                    Write-myLog -level ERROR -messages "User defined ilo and text field both"
                    $Error.Clear()
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.Text="If you define iLO IPs or Text File field, you must define username and Password."
                    Write-myLog -level ERROR -messages "User didn't define Username or password with ilo IPs or text file"
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))) {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define only one field from Text file, ILO IPs or CSV file."
                    Write-myLog -level ERROR -messages "User defined multiple fields among text,iLOIPs and csv"
                    $Error.Clear()
                }
                else{
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="IP validation failed..."
                    Write-myLog -level ERROR -messages "IP validation failed"
                    Write-myLog -level ERROR -messages $ipvalidationmessages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $ipvalidationmessages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
        }
        if($csvresults){
            $csvresults | Export-Csv -path $upgradepath -NoTypeInformation -Force
            Write-myLog -level INFO -messages $csvresults
            if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
            if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
            if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
            if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
            if(![string]::IsNullOrEmpty($csvfile)){Clear-Variable -Name csvfile}
            if(![string]::IsNullOrEmpty($user)){Clear-Variable -Name user}
            if(![string]::IsNullOrEmpty($Password)){Clear-Variable -Name Password}
        }
    }
    catch {
        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $outputtextbox.text="Please define any one field out of ILO IPs, Text File or CSV file to continue"
            Write-myLog -level ERROR -messages "User didn't define any of the field"
        }
        elseif((Test-FileLock -Path $upgradePath)){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="Please close the upgradeinfo file to create a new one."
            Write-myLog -level ERROR -messages "user had the upgradeinfo file open while new one was being created"
        }
        else {
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="some error happened, $($Error[0].exception.message)"
            Write-myLog -level ERROR -messages "some error happened, $($Error[0].exception.message)"
        }
    }
}

function Set_userClick( $object ){


    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")

    #region Form Creation

    #Warning: It is recommended that changes inside this region be handled using the ScriptForm Designer.
    #When working with the ScriptForm designer this region and any changes within may be overwritten.

    #~~< Set_User >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $Set_User = New-Object System.Windows.Forms.Form
    $Set_User.ClientSize = New-Object System.Drawing.Size(434, 180)
    $Set_User.Text = "Set User"
    #~~< Set_result_Label >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $Set_result_Label = New-Object System.Windows.Forms.Label
    $Set_result_Label.Location = New-Object System.Drawing.Point(12, 148)
    $Set_result_Label.Size = New-Object System.Drawing.Size(410, 23)
    $Set_result_Label.TabIndex = 9
    $Set_result_Label.Text = ""
    $Set_result_Label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $Set_result_Label.add_Click({Set_result_LabelClick($Set_result_Label)})
    #~~< Set_User_button >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $Set_User_button = New-Object System.Windows.Forms.Button
    $Set_User_button.Location = New-Object System.Drawing.Point(318, 99)
    $Set_User_button.Size = New-Object System.Drawing.Size(104, 31)
    $Set_User_button.TabIndex = 8
    $Set_User_button.Text = "Set"
    $Set_User_button.UseVisualStyleBackColor = $true
    $Set_User_button.add_Click({Set_User_buttonClick($Set_User_button)})
    #~~< setshowpassword >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $setshowpassword = New-Object System.Windows.Forms.CheckBox
    $setshowpassword.Location = New-Object System.Drawing.Point(319, 45)
    $setshowpassword.Size = New-Object System.Drawing.Size(121, 19)
    $setshowpassword.TabIndex = 7
    $setshowpassword.Text = "Show Password"
    $setshowpassword.UseVisualStyleBackColor = $true
    $setshowpassword.add_CheckedChanged({SetshowpasswordCheckedChanged($setshowpassword)})
    #~~< SetgroupLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $SetgroupLabel = New-Object System.Windows.Forms.Label
    $SetgroupLabel.ImageAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $SetgroupLabel.Location = New-Object System.Drawing.Point(6, 80)
    $SetgroupLabel.Size = New-Object System.Drawing.Size(139, 23)
    $SetgroupLabel.TabIndex = 6
    $SetgroupLabel.Text = "Select an option :"
    $SetgroupLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $SetgroupLabel.add_Click({SetgroupLabelClick($SetgroupLabel)})
    #~~< SetPasswordTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $SetPasswordTextbox = New-Object System.Windows.Forms.TextBox
    $SetPasswordTextbox.Location = New-Object System.Drawing.Point(72, 44)
    $SetPasswordTextbox.Size = New-Object System.Drawing.Size(235, 20)
    $SetPasswordTextbox.TabIndex = 5
    $SetPasswordTextbox.Text = ""
    $SetPasswordTextbox.MaxLength=30
    $SetPasswordTextbox.UseSystemPasswordChar=$true
    $SetPasswordTextbox.add_TextChanged({setPasswordTextChanged($SetPasswordTextbox)})
    #~~< Setusertextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $Setusertextbox = New-Object System.Windows.Forms.TextBox
    $Setusertextbox.Location = New-Object System.Drawing.Point(72, 15)
    $Setusertextbox.Size = New-Object System.Drawing.Size(350, 20)
    $Setusertextbox.TabIndex = 4
    $Setusertextbox.Text = ""
    $Setusertextbox.MaxLength=24
    $Setusertextbox.add_TextChanged({SetusertextboxTextChanged($Setusertextbox)})
    #~~< SetPasswordLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $SetPasswordLabel = New-Object System.Windows.Forms.Label
    $SetPasswordLabel.Location = New-Object System.Drawing.Point(6, 45)
    $SetPasswordLabel.Size = New-Object System.Drawing.Size(60, 19)
    $SetPasswordLabel.TabIndex = 3
    $SetPasswordLabel.Text = "Password"
    $SetPasswordLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $SetPasswordLabel.add_Click({SetPasswordLabelClick($SetPasswordLabel)})
    #~~< SetUserLabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $SetUserLabel = New-Object System.Windows.Forms.Label
    $SetUserLabel.Location = New-Object System.Drawing.Point(6, 15)
    $SetUserLabel.Size = New-Object System.Drawing.Size(60, 23)
    $SetUserLabel.TabIndex = 2
    $SetUserLabel.Text = "User"
    $SetUserLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
    $SetUserLabel.add_Click({SetuserlabelClick($SetUserLabel)})
    #~~< Set_Reset_RB >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $Set_Reset_RB = New-Object System.Windows.Forms.RadioButton
    $Set_Reset_RB.Location = New-Object System.Drawing.Point(190, 106)
    $Set_Reset_RB.Size = New-Object System.Drawing.Size(104, 24)
    $Set_Reset_RB.TabIndex = 1
    $Set_Reset_RB.TabStop = $true
    $Set_Reset_RB.Text = "Reset"
    $Set_Reset_RB.Checked=$false
    $Set_Reset_RB.UseVisualStyleBackColor = $true
    $Set_Reset_RB.add_CheckedChanged({Set_Reset_RBCheckedChanged($Set_Reset_RB)})
    #~~< New_user_RB >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $New_user_RB = New-Object System.Windows.Forms.RadioButton
    $New_user_RB.Location = New-Object System.Drawing.Point(34, 106)
    $New_user_RB.Size = New-Object System.Drawing.Size(104, 24)
    $New_user_RB.TabIndex = 0
    $New_user_RB.TabStop = $true
    $New_user_RB.Text = "New User"
    $New_user_RB.UseVisualStyleBackColor = $true
    $New_user_RB.Checked=$false
    $New_user_RB.add_CheckedChanged({New_user_RBCheckedChanged($New_user_RB)})

    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupbox.controls.add($new_user_rb)
    $groupbox.controls.add($set_reset_rb)

    $Set_User.Controls.Add($Set_result_Label)
    $Set_User.Controls.Add($Set_User_button)
    $Set_User.Controls.Add($setshowpassword)
    $Set_User.Controls.Add($SetgroupLabel)
    $Set_User.Controls.Add($SetPasswordTextbox)
    $Set_User.Controls.Add($Setusertextbox)
    $Set_User.Controls.Add($SetPasswordLabel)
    $Set_User.Controls.Add($SetUserLabel)
    $Set_User.Controls.Add($Set_Reset_RB)
    $Set_User.Controls.Add($New_user_RB)
    $Set_User.add_Load({Set_UserLoad($Set_User)})

#endregion

#region Event Handlers

    function Set_result_LabelClick( $object ){

    }

    function Set_User_buttonClick( $object ){
        $ErrorActionPreference="stop"
        $Set_result_Label.ForeColor="Black"
        $Set_result_Label.Text=""
        try {
            $script:set_user_operation=""
            if([string]::IsNullOrEmpty($Setusertextbox.Text) -or [string]::IsNullOrEmpty($SetPasswordTextbox.Text)){
                throw
            }
            if($New_user_RB.Checked -eq $true){
                $script:setuserresult = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to continue, this will create new user on multiple iLO?", "Confirmation", `
                [System.Windows.Forms.MessageBoxButtons]::OKCancel)
            }
            else{
                $script:setuserresult = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to continue, this will reset password of the user on multiple iLO?", "Confirmation", `
                [System.Windows.Forms.MessageBoxButtons]::OKCancel)
            }

            if ($setuserresult -eq "OK") {
                $script:set_user_operation=""
                if($New_user_RB.Checked -eq $true){
                    $script:set_user_operation="New User"
                }
                else{
                    $script:set_user_operation="Reset"
                }
                $set_user.Close()
            }
            else {
                $script:set_user_operation=""
                $set_user.Close()
            }
        }
        catch {
            if([string]::IsNullOrEmpty($Setusertextbox.Text) -and [string]::IsNullOrEmpty($SetPasswordTextbox.Text)){
                $Set_result_Label.ForeColor="Red"
                $Set_result_Label.Text="Please enter username and password to continue"
            }
            elseif([string]::IsNullOrEmpty($Setusertextbox.Text)){
                $Set_result_Label.ForeColor="Red"
                $Set_result_Label.Text="Please enter username to continue"
            }
            elseif([string]::IsNullOrEmpty($SetPasswordTextbox.Text)){
                $Set_result_Label.ForeColor="Red"
                $Set_result_Label.Text="Please enter password to continue"
            }
        }
    }

    function SetshowpasswordCheckedChanged( $object ){
        if($setshowpassword.checked -eq $true){
            $SetPasswordTextbox.UseSystemPasswordChar=$false
        }
        else{
            $SetPasswordTextbox.UseSystemPasswordChar=$true
        }
    }

    function SetgroupLabelClick( $object ){

    }

    function SetusertextboxTextChanged( $object ){

    }

    function SetPasswordLabelClick( $object ){

    }

    function Set_Reset_RBCheckedChanged( $object ){

    }

    function New_user_RBCheckedChanged( $object ){

    }

    function Set_UserLoad( $object ){

    }

    function setPasswordTextChanged( $object ){

    }
    function SetuserlabelClick( $object ){
    }
    Write-myLog -level INFO -messages "User clicked on Set User button"
    $script:set_user_operation=""
    $ErrorActionPreference="stop"
    $outputtextbox.ForeColor="Black"
    $outputtextbox.text="Validating information..."
    Start-Sleep -Seconds 1
    try {
        if((Test-FileLock -Path $setuserPath)){
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $outputtextbox.text="Please wait..."
            Start-Sleep -Seconds 1
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and (![string]::IsNullOrEmpty($PasswordfileText.Text))){

            try {
                if((![string]::IsNullOrEmpty($UsernameTextbox.Text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.Text))){
                    $outputtextbox.text="Please wait..."
                    Start-Sleep -Seconds 1
                    throw
                }
                $messages=test-csv -path $PasswordfileText.Text
                if(!($messages)){
                    $outputtextbox.text="CSV is validated.."
                    Write-myLog -level INFO -messages "CSV validated"
                    Write-myLog -level INFO -messages "CSV file path : $($PasswordfileText.Text)"
                    Start-Sleep 2
                    $csvfile=import-csv -path $passwordfiletext.text  | Sort-Object iloIP -Unique
                    $ProgressBar.Maximum=$csvfile.count
                    $ProgressBar.Value=0
                    $ProgressBar.Step=1
                    $OutputTextBox.Text="Please wait........."
                    $set_user.showdialog()

                    if($set_user_operation -eq "New User"){
                        Write-myLog -level INFO -messages "User clicked on new user button"
                        $OutputTextBox.Text=("iLO IP"+","+"User Creation Status"+","+"Issue")
                        $csvresults=foreach($item in $csvfile) {
                            try {
                                $ErrorActionPreference="stop"
                                $connection=Connect-HPEiLO $Item.iloIP -Username $item.Username -Password $item.password `
                                -WarningAction Ignore
                                $users=$connection | get-hpeilouser

                                if($users.userinformation.username -contains $setusertextbox.text){
                                    throw
                                }

                                $newuser=Add-HPEiLOUser -Connection $connection -Username $Setusertextbox.Text -Password $SetPasswordTextbox.text `
                                -LoginName $Setusertextbox.Text -UserConfigPrivilege Yes -iLOConfigPrivilege Yes -RemoteConsolePrivilege Yes `
                                -VirtualMediaPrivilege Yes -VirtualPowerAndResetPrivilege
                                if($newuser.status -eq "Error"){
                                    throw
                                }
                                Write-myLog -messages "Connection to $($item.iloip) is secure"
                                $Status="Success"
                                $Issue="No Error"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)

                                $ProgressBar.PerformStep()
                            }
                            catch {
                                if($Error[0].Exception.Message -match  `
                                "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                    try {
                                        $ErrorActionPreference="stop"
                                        $connection=Connect-HPEiLO $Item.iloIP -Username $item.Username -Password $item.password `
                                        -DisableCertificateAuthentication -WarningAction Ignore
                                        $users=$connection | get-hpeilouser

                                        if($users.userinformation.username -contains $setusertextbox.text){
                                            throw
                                        }
                                        $newuser=Add-HPEiLOUser -Connection $connection -Username $Setusertextbox.Text `
                                        -Password $SetPasswordTextbox.text -LoginName $Setusertextbox.Text -UserConfigPrivilege Yes `
                                        -iLOConfigPrivilege Yes -RemoteConsolePrivilege Yes `
                                        -VirtualMediaPrivilege Yes -VirtualPowerAndResetPrivilege
                                        if($newuser.status -eq "Error"){
                                            throw
                                        }
                                        Write-myLog -messages "Connection to $($item.iloip) is unsecure"
                                        $Status="Success"
                                        $Issue="No Error"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                    catch {
                                        if($users.userinformation.username -contains $setusertextbox.text){
                                            $status="Failure"
                                            $Issue="User already exist"
                                            $OutputTextBox.AppendText("`n")
                                            $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                            $ProgressBar.PerformStep()
                                        }
                                        elseif($newuser.status -eq "Error"){
                                            $status=$newuser.status
                                            $Issue=$newuser.statusinfo.message
                                        }
                                        else{
                                            $status="Failure"
                                            $Issue=$($Error[0].Exception.Message)
                                            $OutputTextBox.AppendText("`n")
                                            $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                            $ProgressBar.PerformStep()
                                        }
                                    }
                                }
                                else{
                                    if($users.userinformation.username -contains $setusertextbox.text){
                                        $status="Failure"
                                        $Issue="User already exist"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                    elseif($newuser.status -eq "Error"){
                                        $status=$newuser.status
                                        $Issue=$newuser.statusinfo.message
                                    }
                                    else{
                                        $status="Failure"
                                        $Issue=$($Error[0].Exception.Message)
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                }
                            }

                            [PSCustomObject]@{
                                'iLO IP'=$Item.iloip
                                'New User Status'=$Status
                                'Error'=$Issue
                            }
                        }
                    }
                    elseif($set_user_operation -eq "Reset"){
                        Write-myLog -level INFO -messages "User clicked on Reset button"
                        $OutputTextBox.Text=("iLO IP"+","+"Password Reset Status"+","+"Issue")
                        $csvresults=foreach($item in $csvfile) {
                            try {
                                $ErrorActionPreference="stop"
                                $connection=Connect-HPEiLO $Item.iloIP -Username $item.Username -Password $item.password `
                                -WarningAction Ignore
                                $users=$connection | get-hpeilouser

                                if(!($users.userinformation.username -contains $setusertextbox.text)){
                                    throw
                                }

                                $resetuser=Set-hpeilouser -connection $connection -LoginName $setusertextbox.text -newpassword $setpasswordtextbox.text
                                if($resetuser.status -eq "Error"){
                                    throw
                                }
                                Write-myLog -messages "Connection to $($item.iloIP) is secure"
                                $Status="Success"
                                $Issue="No Error"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)

                                $ProgressBar.PerformStep()
                            }
                            catch {
                                if($Error[0].Exception.Message -match  `
                                "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel." `
                                -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                    try {
                                        $ErrorActionPreference="stop"
                                        $connection=Connect-HPEiLO $Item.iloIP -Username $item.Username -Password $item.password `
                                        -DisableCertificateAuthentication -WarningAction Ignore
                                        $users=$connection | get-hpeilouser
                                        if(!($users.userinformation.username -contains $setusertextbox.text)){
                                            throw
                                        }

                                        $resetuser=Set-hpeilouser -connection $connection -LoginName $setusertextbox.text `
                                        -newpassword $setpasswordtextbox.text
                                        if($resetuser.status -eq "Error"){
                                            throw
                                        }
                                        Write-myLog -messages "Connection to $($item.iloIP) is unsecure"
                                        $Status="Success"
                                        $Issue="No Error"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)

                                        $ProgressBar.PerformStep()
                                    }
                                    catch {
                                        if(!($users.userinformation.username -contains $setusertextbox.text) -and `
                                        !([string]::IsNullOrEmpty($users.userinformation.username))){

                                            $status="Failure"
                                            $Issue="User doesn't exist"
                                            $OutputTextBox.AppendText("`n")
                                            $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                            $ProgressBar.PerformStep()
                                        }
                                        elseif($resetuser.status -eq "Error"){
                                            $status=$resetuser.status
                                            $Issue=$resetuser.statusinfo.message
                                        }
                                        else{
                                            $status="Failure"
                                            $Issue="$($Error[0].Exception.Message)"
                                            $OutputTextBox.AppendText("`n")
                                            $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                            $ProgressBar.PerformStep()
                                        }
                                    }
                                }
                                else{
                                    if(!($users.userinformation.username -contains $setusertextbox.text) -and `
                                    !([string]::IsNullOrEmpty($users.userinformation.username))){

                                        $status="Failure"
                                        $Issue="User doesn't exist"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                    elseif($resetuser.status -eq "Error"){
                                        $status=$resetuser.status
                                        $Issue=$resetuser.statusinfo.message
                                    }
                                    else{
                                        $status="Failure"
                                        $Issue="$($Error[0].Exception.Message)"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                }
                            }

                            [PSCustomObject]@{
                                'iLO IP'=$Item.iloip
                                'New User Status'=$Status
                                'Error'=$Issue
                            }
                        }
                    }
                    elseif([string]::IsNullOrEmpty($set_user_operation)){
                        $outputtextbox.ForeColor="Red"
                        $outputtextbox.text="User cancelled the operation"
                        Write-myLog -level ERROR -messages "User cancelled the process"
                    }
                }
                else {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="CSV validation failed..."
                    Write-myLog -level ERROR -messages "CSV validation failed"
                    Write-myLog -level ERROR -messages $messages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $messages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
            catch {
                $ProgressBar.Value=0
                $outputtextbox.ForeColor="Red"
                $outputtextbox.text="You cannot define username or password with CSV file"
                Write-myLog -level ERROR -messages "User defined username or password with CSV file"
                Start-Sleep -Seconds 1
            }
        }
        else{
            try {

                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }
                if((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $outputtextbox.ForeColor="Black"
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((![string]::IsNullOrEmpty($FilePathTextBox.text))){
                    $ipvalidationmessages=test-iloIP -path $FilePathTextBox.Text
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$fileiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined text file with successful validation"
                    Write-myLog -level INFO -messages "Text file path : $($FilePathTextBox.Text)"
                }
                elseif(![string]::IsNullOrEmpty($iLOTextbox.text)){
                    $ipvalidationmessages=test-iloIpstring -IPs $textiloips
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$textiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined manual iLO IPs with successful validation"
                }
                $ProgressBar.Maximum=$iloIPs.count
                $ProgressBar.Value=0
                $ProgressBar.Step=1
                $outputtextbox.ForeColor="Black"
                $OutputTextBox.Text="Please wait........."
                $set_user.showdialog()
                if($set_user_operation -eq "New User"){
                    Write-myLog -level INFO -messages "User clicked on new user button"
                    $OutputTextBox.Text=("iLO IP"+","+"User Creation Status"+","+"Issue")
                    $csvresults=foreach($iloip in $iloIPs) {
                        try {
                            $ErrorActionPreference="stop"
                            $connection=Connect-HPEiLO $iloIP -Username $User -Password $password `
                            -WarningAction Ignore

                            $users=$connection | get-hpeilouser
                            if($users.userinformation.username -contains $setusertextbox.text){
                                throw
                            }

                            $newuser=Add-HPEiLOUser -Connection $connection -Username $Setusertextbox.Text -Password $SetPasswordTextbox.text `
                            -LoginName $Setusertextbox.Text -UserConfigPrivilege Yes -iLOConfigPrivilege Yes -RemoteConsolePrivilege Yes `
                            -VirtualMediaPrivilege Yes -VirtualPowerAndResetPrivilege Yes
                            if($newuser.status -eq "Error"){
                                throw
                            }
                            Write-myLog -messages "Connection is $($iloip) is secure"
                            $Status="Success"
                            $Issue="No Error"
                            $OutputTextBox.AppendText("`n")
                            $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)

                            $ProgressBar.PerformStep()
                        }
                        catch {
                            if($Error[0].Exception.Message -match  `
                            "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel." `
                            -or $Error[0].Exception.Message -match  "The SSL connection could not be established, see inner exception" ){
                                try {
                                    $ErrorActionPreference="stop"
                                    $connection=Connect-HPEiLO $iloIP -Username $User -Password $password `
                                    -DisableCertificateAuthentication -WarningAction Ignore

                                    $users=$connection | get-hpeilouser
                                    if($users.userinformation.username -contains $setusertextbox.text){
                                        throw
                                    }

                                    $newuser=Add-HPEiLOUser -Connection $connection -Username $Setusertextbox.Text -Password $SetPasswordTextbox.text `
                                    -LoginName $Setusertextbox.Text -UserConfigPrivilege Yes -iLOConfigPrivilege Yes -RemoteConsolePrivilege Yes `
                                    -VirtualMediaPrivilege Yes -VirtualPowerAndResetPrivilege Yes
                                    if($newuser.status -eq "Error"){
                                        throw
                                    }
                                    Write-myLog -messages "Connection is $($iloip) is unsecure"
                                    $Status="Success"
                                    $Issue="No Error"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)

                                    $ProgressBar.PerformStep()
                                }
                                catch {
                                    if($users.userinformation.username -contains $setusertextbox.text){
                                        $status="Failure"
                                        $Issue="User already exist"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                    elseif($newuser.status -eq "Error"){
                                        $status=$newuser.status
                                        $Issue=$newuser.statusinfo.message
                                    }
                                    else{
                                        $status="Failure"
                                        $Issue="$($Error[0].Exception.Message)"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                }
                            }
                            else{
                                if($users.userinformation.username -contains $setusertextbox.text){
                                    $status="Failure"
                                    $Issue="User already exist"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                                elseif($newuser.status -eq "Error"){
                                    $status=$newuser.status
                                    $Issue=$newuser.statusinfo.message
                                }
                                else{
                                    $status="Failure"
                                    $Issue="$($Error[0].Exception.Message)"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                            }
                        }

                        [PSCustomObject]@{
                            'iLO IP'=$iloip
                            'New User Status'=$Status
                            'Error'=$Issue
                        }
                    }
                }
                elseif($set_user_operation -eq "Reset"){
                    Write-myLog -level INFO -messages "User clicked on reset button"
                    $OutputTextBox.Text=("iLO IP"+","+"Password Reset Status"+","+"Issue")
                    $csvresults=foreach($iloip in $iloIPs) {
                        try {
                            $ErrorActionPreference="stop"
                            $connection=Connect-HPEiLO $iloIP -Username $User -Password $password `
                            -WarningAction Ignore

                            $users=$connection | get-hpeilouser
                            if(!($users.userinformation.username -contains $setusertextbox.text)){
                                throw
                            }

                            $resetuser=Set-hpeilouser -connection $connection -loginname $setusertextbox.text -newpassword $setpasswordtextbox.text
                            if($resetuser.status -eq "Error"){
                                throw
                            }
                            Write-myLog -messages "Connection to $($iloip) is secure"
                            $Status="Success"
                            $Issue="No Error"
                            $OutputTextBox.AppendText("`n")
                            $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)

                            $ProgressBar.PerformStep()
                        }
                        catch {
                            if($Error[0].Exception.Message -match  `
                            "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel." `
                            -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                try {
                                    $ErrorActionPreference="stop"
                                    $connection=Connect-HPEiLO $iloIP -Username $User -Password $password `
                                    -DisableCertificateAuthentication -WarningAction Ignore

                                    $users=$connection | get-hpeilouser
                                    if(!($users.userinformation.username -contains $setusertextbox.text)){
                                        throw
                                    }

                                    $resetuser=Set-hpeilouser -connection $connection -loginname $setusertextbox.text `
                                    -newpassword $setpasswordtextbox.text
                                    if($resetuser.status -eq "Error"){
                                        throw
                                    }
                                    Write-myLog -messages "Connection to $($iloip) is unsecure"
                                    $Status="Success"
                                    $Issue="No Error"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                                catch {
                                    if(!($users.userinformation.username -contains $setusertextbox.text) -and `
                                    !([string]::IsNullOrEmpty($users.userinformation.username))){

                                        $status="Failure"
                                        $Issue="User doesn't exist"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                    elseif($resetuser.status -eq "Error"){
                                        $status=$resetuser.Status
                                        $Issue=$resetuser.statusinfo.message
                                    }
                                    else{
                                        $status="Failure"
                                        $Issue="$($Error[0].Exception.Message)"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                }
                            }
                            else{
                                if(!($users.userinformation.username -contains $setusertextbox.text) -and `
                                !([string]::IsNullOrEmpty($users.userinformation.username))){

                                    $status="Failure"
                                    $Issue="User doesn't exist"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                                elseif($resetuser.status -eq "Error"){
                                    $status=$resetuser.Status
                                    $Issue=$resetuser.statusinfo.message
                                }
                                else{
                                    $status="Failure"
                                    $Issue="$($Error[0].Exception.Message)"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                            }
                        }

                        [PSCustomObject]@{
                            'iLO IP'=$iloip
                            'New User Status'=$Status
                            'Error'=$Issue
                        }
                    }
                }
                elseif([string]::IsNullOrEmpty($set_user_operation)){
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="User cancelled the operation"
                    Write-myLog -level ERROR -messages "User cancelled the process"
                }
            }
            catch {
                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User defined multiple fields"
                    $Error.Clear()
                }

                elseif((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User didn't define any of the field along with username and password"
                    $Error.Clear()
                }
                elseif((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($ilotextbox.text))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs to continue.."
                    Write-myLog -level ERROR -messages "User defined ilo and text field both"
                    $Error.Clear()
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.Text="If you define iLO IPs or Text File field, you must define username and Password."
                    Write-myLog -level ERROR -messages "User didn't define Username or password with ilo IPs or text file"
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))) {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define only one field from Text file, ILO IPs or CSV file."
                    Write-myLog -level ERROR -messages "User defined multiple fields among text,iLOIPs and csv"
                    $Error.Clear()
                }
                else{
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="IP validation failed..."
                    Write-myLog -level ERROR -messages "IP validation failed"
                    Write-myLog -level ERROR -messages $ipvalidationmessages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $ipvalidationmessages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
        }
        if($csvresults){
            $csvresults | Export-Csv -path $setuserpath -NoTypeInformation -Force
            Write-myLog -level INFO -messages $csvresults
            if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
            if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
            if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
            if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
            if(![string]::IsNullOrEmpty($csvfile)){Clear-Variable -Name csvfile}
            if(![string]::IsNullOrEmpty($user)){Clear-Variable -Name user}
            if(![string]::IsNullOrEmpty($Password)){Clear-Variable -Name Password}
        }
    }
    catch {
        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $outputtextbox.text="Please define any one field out of ILO IPs, Text File or CSV file to continue"
            Write-myLog -level ERROR -messages "User didn't define any of the field"
        }
        elseif((Test-FileLock -Path $setuserPath)){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="Please close the setuserinfo file to create a new one."
            Write-myLog -level ERROR -messages "user had the Setuserinfo file open while new one was being created"
        }
        else {
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="some error happened, $($Error[0].exception.message)"
            Write-myLog -level ERROR -messages "some error happened, $($Error[0].exception.message)"
        }
    }
}

function BRClick( $object ){


    #region Form Creation

    #Warning: It is recommended that changes inside this region be handled using the ScriptForm Designer.
    #When working with the ScriptForm designer this region and any changes within may be overwritten.
    #~~< BRform >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $BRform = New-Object System.Windows.Forms.Form
    $BRform.ClientSize = New-Object System.Drawing.Size(464, 132)
    $BRform.Text = "Backup/Restore Form"
    #~~< BKresultlabel >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $BKresultlabel = New-Object System.Windows.Forms.Label
    $BKresultlabel.Location = New-Object System.Drawing.Point(13, 97)
    $BKresultlabel.Size = New-Object System.Drawing.Size(439, 23)
    $BKresultlabel.TabIndex = 6
    $BKresultlabel.Text = ""
    #~~< bkfilepath >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $bkfilepath = New-Object System.Windows.Forms.Label
    $bkfilepath.Location = New-Object System.Drawing.Point(12, 12)
    $bkfilepath.Size = New-Object System.Drawing.Size(105, 20)
    $bkfilepath.TabIndex = 5
    $bkfilepath.Text = "Backup File Path : "
    $bkfilepath.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $bkfilepath.add_Click({BkfilepathClick($bkfilepath)})
    #~~< RestoreButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $RestoreButton = New-Object System.Windows.Forms.Button
    $RestoreButton.Location = New-Object System.Drawing.Point(377, 53)
    $RestoreButton.Size = New-Object System.Drawing.Size(75, 23)
    $RestoreButton.TabIndex = 4
    $RestoreButton.Text = "Restore"
    $RestoreButton.UseVisualStyleBackColor = $true
    $RestoreButton.add_Click({RestoreButtonClick($RestoreButton)})
    #~~< BackupButton >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $BackupButton = New-Object System.Windows.Forms.Button
    $BackupButton.Location = New-Object System.Drawing.Point(12, 52)
    $BackupButton.Size = New-Object System.Drawing.Size(74, 24)
    $BackupButton.TabIndex = 3
    $BackupButton.Text = "Backup"
    $BackupButton.UseVisualStyleBackColor = $true
    $BackupButton.add_Click({BackupButtonClick($BackupButton)})
    #~~< BkTextbox >~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    $BkTextbox = New-Object System.Windows.Forms.TextBox
    $BkTextbox.Location = New-Object System.Drawing.Point(123, 13)
    $BkTextbox.Size = New-Object System.Drawing.Size(329, 20)
    $BkTextbox.TabIndex = 2
    $BkTextbox.Text = ""
    $BkTextbox.AutoCompleteMode="SuggestAppend"
    $BkTextbox.AutoCompleteSource="FileSystem"
    $BkTextbox.add_TextChanged({BkTextboxTextChanged($BkTextbox)})
    $BRform.Controls.Add($BKresultlabel)
    $BRform.Controls.Add($bkfilepath)
    $BRform.Controls.Add($RestoreButton)
    $BRform.Controls.Add($BackupButton)
    $BRform.Controls.Add($BkTextbox)

    #endregion

    #region Event Handlers

    function BkfilepathClick( $object ){

    }

    function RestoreButtonClick( $object ){
        $ErrorActionPreference="stop"
        $BKresultlabel.ForeColor="Black"
        $BKresultlabel.text="User has choosen to restore the backup on an ILO"
        $script:BRoperation=""
        try {
            if(([string]::IsNullOrEmpty($BkTextbox.Text))){
                throw
            }
            $backup_file_validation=test-backupfile -path $BkTextbox.Text
            if(!([string]::IsNullOrEmpty($backup_file_validation))){
                throw
            }
            $script:BRresult = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to continue, this will restore backup on iLO?", "Confirmation", `
            [System.Windows.Forms.MessageBoxButtons]::OKCancel)
            if($script:BRresult -eq "OK"){
                $script:BRoperation="Restore"
                $BRform.Close()
            }
            else{
                $BRform.close()
            }
        }
        catch {
            if([string]::IsNullOrEmpty($BkTextbox.Text)){
                $BKresultlabel.ForeColor="Red"
                $BKresultlabel.Text="You must choose restore path for backup file to continue.."
            }
            elseif(!([string]::IsNullOrEmpty($backup_file_validation))){
                $BKresultlabel.ForeColor="Red"
                $BKresultlabel.Text=$backup_file_validation
            }
        }
    }

    function BackupButtonClick( $object ){
        $BKresultlabel.text="User has choosen to backup multiple ILO"
        $ErrorActionPreference="Stop"
        $BKresultlabel.ForeColor="Black"
        $script:BRoperation=""
        try {
            $script:setuserresult = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to continue, this will create backup of multiple iLO?", "Confirmation", `
            [System.Windows.Forms.MessageBoxButtons]::OKCancel)
            if($script:setuserresult -eq "OK"){
                $script:BRoperation="Backup"
                $BRform.Close()
            }
            else{
                $BRform.close()
            }
        }
        catch {
            {1:<#Do this if a terminating exception happens#>}
        }
    }

    function BkTextboxTextChanged( $object ){

    }
    Write-myLog -level INFO -messages "User clicked on Backup/Restore button"
    $ErrorActionPreference="stop"
    $outputtextbox.ForeColor="Black"
    $outputtextbox.text="Validating information..."
    $script:BRoperation=""
    Start-Sleep -Seconds 1
    try {
        if((Test-FileLock -Path $BRPath)){
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $outputtextbox.text="Please wait..."
            Start-Sleep -Seconds 1
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and (![string]::IsNullOrEmpty($PasswordfileText.Text))){

            try {
                if((![string]::IsNullOrEmpty($UsernameTextbox.Text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.Text))){
                    $outputtextbox.text="Please wait..."
                    Start-Sleep -Seconds 1
                    throw
                }
                $messages=test-csv -path $PasswordfileText.Text
                if(!($messages)){
                    $outputtextbox.text="CSV is validated.."
                    Write-myLog -level INFO -messages "CSV validated"
                    Write-myLog -level INFO -messages "CSV file path : $($PasswordfileText.Text)"
                    Start-Sleep 2
                    $csvfile=import-csv -path $passwordfiletext.text | Sort-Object iloIP -Unique
                    $ProgressBar.Maximum=$csvfile.count
                    $ProgressBar.Value=0
                    $ProgressBar.Step=1
                    $OutputTextBox.Text="Please wait........."
                    $BRform.ShowDialog()
                    if($broperation -eq "Restore"){
                        Write-myLog -level INFO -messages "User clicked on restore button"
                        $OutputTextBox.Text=("iLO IP"+","+"Restore Status"+","+"Issue")
                        try {
                            if($csvfile.count -gt 1){
                                throw
                            }
                            $csvresults=foreach($item in $csvfile) {
                                try {
                                    $ErrorActionPreference="stop"
                                    $connection=Connect-HPEiLO $Item.iloIP -Username $item.Username -Password $item.password `
                                    -WarningAction Ignore

                                    $restore=Restore-HPEiLOSetting -Connection $connection -BackupFileLocation $BkTextbox.Text `
                                    -UploadTimeout 1000 -confirm:$false
                                    if($restore.status -eq "Error"){
                                        throw
                                    }
                                    Write-myLog -messages "Connection to $($item.iloip) is secure"
                                    $Status="Success"
                                    $Issue="No Error"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)

                                    $ProgressBar.PerformStep()
                                }
                                catch {
                                    if($Error[0].Exception.Message -match  `
                                    "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                    -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                        try {
                                            $ErrorActionPreference="stop"
                                            $connection=Connect-HPEiLO $Item.iloIP -Username $item.Username -Password $item.password `
                                            -DisableCertificateAuthentication -WarningAction Ignore
                                            $restore=Restore-HPEiLOSetting -Connection $connection -BackupFileLocation $BkTextbox.Text `
                                            -UploadTimeout 1000 -confirm:$false
                                            if($restore.status -eq "Error"){
                                                throw
                                            }
                                            Write-myLog -messages "Connection to $($item.iloip) is unsecure"
                                            $Status="Success"
                                            $Issue="No Error"
                                            $OutputTextBox.AppendText("`n")
                                            $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                            $ProgressBar.PerformStep()                                         }
                                        catch {
                                            if($restore.status -eq "Error"){
                                                $status=$restore.status
                                                $Issue=$restore.statusinfo.message
                                            }
                                            else{
                                                $status="Failure"
                                                $Issue="$($Error[0].exception.message)"
                                            }
                                            $OutputTextBox.AppendText("`n")
                                            $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                            $ProgressBar.PerformStep()
                                        }
                                    }
                                    else{
                                        if($restore.status -eq "Error"){
                                            $status=$restore.status
                                            $Issue=$restore.statusinfo.message
                                        }
                                        else{
                                            $status="Failure"
                                            $Issue="$($Error[0].exception.message)"
                                        }
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                }

                                [PSCustomObject]@{
                                    'iLO IP'=$Item.iloip
                                    'New User Status'=$Status
                                    'Error'=$Issue
                                }
                            }
                        }
                        catch {
                            $outputtextbox.ForeColor="Red"
                            $outputtextbox.text="You cannot choose to restore backup on multiple iLO"
                            Write-myLog -level ERROR -messages "User chose to restore backup on mulitple iLO"
                        }
                    }
                    elseif($broperation -eq "Backup"){
                        Write-myLog -level INFO -messages "User clicked on Backup Button"
                        $OutputTextBox.Text=("iLO IP"+","+"Backup Status"+","+"Issue")
                        $csvresults=foreach($item in $csvfile) {
                            try {
                                $ErrorActionPreference="stop"
                                $connection=Connect-HPEiLO $Item.iloIP -Username $item.Username -Password $item.password `
                                -WarningAction Ignore

                                $backup=Backup-HPEiLOSetting -Connection $connection -BackupFileLocation "$filedirectory\$($item.iloip)_backup.bak"
                                if($backup.status -eq "Error"){
                                    throw
                                }
                                Write-myLog -messages "Connection to $($item.iloip) is secure"
                                $Status="Success"
                                $Issue="No Error"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)

                                $ProgressBar.PerformStep()
                            }
                            catch {
                                if($Error[0].Exception.Message -match  `
                                "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                    try {
                                        $ErrorActionPreference="stop"
                                        $connection=Connect-HPEiLO $Item.iloIP -Username $item.Username -Password $item.password `
                                        -DisableCertificateAuthentication -WarningAction Ignore
                                        $backup=Backup-HPEiLOSetting -Connection $connection -BackupFileLocation `
                                        "$filedirectory\$($item.iloip)_backup.bak"
                                        if($backup.status -eq "Error"){
                                            throw
                                        }
                                        Write-myLog -messages "Connection to $($item.iloip) is unsecure"
                                        $Status="Success"
                                        $Issue="No Error"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                    catch {
                                        if($backup.status -eq "Error"){
                                            $status=$backup.status
                                            $Issue=$backup.statusinfo.message
                                        }
                                        else{
                                            $status="Failure"
                                            $Issue="$($Error[0].exception.message)"
                                        }
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                }
                                else{
                                    if($backup.status -eq "Error"){
                                        $status=$backup.status
                                        $Issue=$backup.statusinfo.message
                                    }
                                    else{
                                        $status="Failure"
                                        $Issue="$($Error[0].exception.message)"
                                    }
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($item.iloIP+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                            }

                            [PSCustomObject]@{
                                'iLO IP'=$Item.iloip
                                'New User Status'=$Status
                                'Error'=$Issue
                            }
                        }
                    }
                    else{
                        $outputtextbox.ForeColor="Red"
                        $outputtextbox.Text="User has cancelled the process."
                        Write-myLog -level ERROR -messages "User cancelled the process"
                    }
                }
                else {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="CSV validation failed..."
                    Write-myLog -level ERROR -messages "CSV validation failed"
                    Write-myLog -level ERROR -messages $messages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $messages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
            catch {
                $ProgressBar.Value=0
                $outputtextbox.ForeColor="Red"
                $outputtextbox.text="You cannot define username or password with CSV file"
                Write-myLog -level ERROR -messages "User defined username or password with CSV file"
                Start-Sleep -Seconds 1
            }
        }
        else{
            try {

                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }
                if((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $outputtextbox.ForeColor="Black"
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((![string]::IsNullOrEmpty($FilePathTextBox.text))){
                    $ipvalidationmessages=test-iloIP -path $FilePathTextBox.Text
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$fileiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined text file with successful validation"
                    Write-myLog -level INFO -messages "Text file path : $($FilePathTextBox.Text)"
                }
                elseif(![string]::IsNullOrEmpty($iLOTextbox.text)){
                    $ipvalidationmessages=test-iloIpstring -IPs $textiloips
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$textiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined manual iLO IPs with successful validation"
                }
                $ProgressBar.Maximum=$iloIPs.count
                $ProgressBar.Value=0
                $ProgressBar.Step=1
                $outputtextbox.ForeColor="Black"
                $OutputTextBox.Text="Please wait........."
                $BRform.ShowDialog()

                if($broperation -eq "Restore"){
                    Write-myLog -level INFO -messages "User clicked on Restore button"
                    $OutputTextBox.Text=("iLO IP"+","+"Restore Status"+","+"Issue")
                    try {
                        if($iloIPs.count -gt 1){
                            throw
                        }
                        $csvresults=foreach($iloIP in $iloIPs) {
                            try {
                                $ErrorActionPreference="stop"
                                $connection=Connect-HPEiLO $iloIP -Username $User -Password $password `
                                -WarningAction Ignore

                                $restore=Restore-HPEiLOSetting -Connection $connection -BackupFileLocation $BkTextbox.Text -UploadTimeout 1000 `
                                -confirm:$false
                                if($restore.status -eq "Error"){
                                    throw
                                }
                                Write-myLog -messages "Connection to $($iloIP) is secure"
                                $Status="Success"
                                $Issue="No Error"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                $ProgressBar.PerformStep()
                            }
                            catch {
                                if($Error[0].Exception.Message -match  `
                                "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                    try {
                                        $ErrorActionPreference="stop"
                                        $connection=Connect-HPEiLO $iloIP -Username $User -Password $password `
                                        -DisableCertificateAuthentication -WarningAction Ignore

                                        $restore=Restore-HPEiLOSetting -Connection $connection -BackupFileLocation $BkTextbox.Text -UploadTimeout 1000 `
                                        -confirm:$false
                                        if($restore.status -eq "Error"){
                                            throw
                                        }
                                        Write-myLog -messages "Connection to $($iloIP) is unsecure"
                                        $Status="Success"
                                        $Issue="No Error"
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                    catch {
                                        if($restore.status -eq "Error"){
                                            $status=$restore.status
                                            $Issue=$restore.statusinfo.message
                                        }
                                        else{
                                            $status="Failure"
                                            $Issue="$($Error[0].exception.message)"
                                        }
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                        $ProgressBar.PerformStep()
                                    }
                                }
                                else{
                                    if($restore.status -eq "Error"){
                                        $status=$restore.status
                                        $Issue=$restore.statusinfo.message
                                    }
                                    else{
                                        $status="Failure"
                                        $Issue="$($Error[0].exception.message)"
                                    }
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                            }

                            [PSCustomObject]@{
                                'iLO IP'=$iloip
                                'Restore Status'=$Status
                                'Error'=$Issue
                            }
                        }
                    }
                    catch {
                        $outputtextbox.ForeColor="Red"
                        $outputtextbox.text="You cannot choose to restore backup on multiple iLO"
                        Write-myLog -level ERROR -messages "User choose to restore backup on mulitple iLO"
                    }
                }
                elseif($broperation -eq "Backup"){
                    Write-myLog -level INFO -messages "User clicked on Backup button"
                    $OutputTextBox.Text=("iLO IP"+","+"Backup Status"+","+"Issue")
                    $csvresults=foreach($iloIP in $iloIPs) {
                        try {
                            $ErrorActionPreference="stop"
                            $connection=Connect-HPEiLO $iloIP -Username $User -Password $password `
                            -WarningAction Ignore

                            $backup=Backup-HPEiLOSetting -Connection $connection -BackupFileLocation "$filedirectory\$($iloip)_backup.bak"
                            if($backup.status -eq "Error"){
                                throw
                            }
                            Write-myLog -messages "Connection to $($iloIP) is secure"
                            $Status="Success"
                            $Issue="No Error"
                            $OutputTextBox.AppendText("`n")
                            $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)

                            $ProgressBar.PerformStep()
                        }
                        catch {
                            if($Error[0].Exception.Message -match  `
                            "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                            -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                try {
                                    $ErrorActionPreference="stop"
                                    $connection=Connect-HPEiLO $iloIP -Username $User -Password $password `
                                    -DisableCertificateAuthentication -WarningAction Ignore
                                    $backup=Backup-HPEiLOSetting -Connection $connection -BackupFileLocation "$filedirectory\$($iloip)_backup.bak"
                                    if($backup.status -eq "Error"){
                                        throw
                                    }
                                    Write-myLog -messages "Connection to $($iloIP) is unsecure"
                                    $Status="Success"
                                    $Issue="No Error"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                                catch {
                                    if($backup.status -eq "Error"){
                                        $status=$backup.status
                                        $Issue=$backup.statusinfo.message
                                    }
                                    else{
                                        $status="Failure"
                                        $Issue="$($Error[0].exception.message)"
                                    }
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                            }
                            else{
                                if($backup.status -eq "Error"){
                                    $status=$backup.status
                                    $Issue=$backup.statusinfo.message
                                }
                                else{
                                    $status="Failure"
                                    $Issue="$($Error[0].exception.message)"
                                }
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($iloIP+","+$Status+","+$Issue)
                                $ProgressBar.PerformStep()
                            }
                        }

                        [PSCustomObject]@{
                            'iLO IP'=$iloip
                            'Backup Status'=$Status
                            'Error'=$Issue
                        }
                    }
                }
                else{
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.Text="User has cancelled the process."
                    Write-myLog -level ERROR -messages "User cancelled the process"
                }
            }
            catch {
                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User defined multiple fields"
                    $Error.Clear()
                }

                elseif((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User didn't define any of the field along with username and password"
                    $Error.Clear()
                }
                elseif((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($ilotextbox.text))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs to continue.."
                    Write-myLog -level ERROR -messages "User defined ilo and text field both"
                    $Error.Clear()
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.Text="If you define iLO IPs or Text File field, you must define username and Password."
                    Write-myLog -level ERROR -messages "User didn't define Username or password with ilo IPs or text file"
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))) {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define only one field from Text file, ILO IPs or CSV file."
                    Write-myLog -level ERROR -messages "User defined multiple fields among text,iLOIPs and csv"
                    $Error.Clear()
                }
                else{
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="IP validation failed..."
                    Write-myLog -level ERROR -messages "IP validation failed"
                    Write-myLog -level ERROR -messages $ipvalidationmessages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $ipvalidationmessages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
        }
        if($csvresults){
            $csvresults | Export-Csv -path $BRpath -NoTypeInformation -Force
            Write-myLog -level INFO -messages $csvresults
            if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
            if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
            if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
            if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
            if(![string]::IsNullOrEmpty($csvfile)){Clear-Variable -Name csvfile}
            if(![string]::IsNullOrEmpty($user)){Clear-Variable -Name user}
            if(![string]::IsNullOrEmpty($Password)){Clear-Variable -Name Password}
        }
    }
    catch {
        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $outputtextbox.text="Please define any one field out of ILO IPs, Text File or CSV file to continue"
            Write-myLog -level ERROR -messages "User didn't define any of the field"
        }
        elseif((Test-FileLock -Path $BRPath)){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="Please close the BackupRestoreinfo file to create a new one."
            Write-myLog -level ERROR -messages "user had the BackupRestoreinfo file open while new one was being created"
        }
        else {
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="some error happened, $($Error[0].exception.message)"
            Write-myLog -level ERROR -messages "some error happened, $($Error[0].exception.message)"
        }
    }
}

function HealthButtonClick( $object ){
    Write-myLog -level INFO -messages "User clicked on Health Button"
    $ErrorActionPreference="stop"
    $outputtextbox.ForeColor="Black"
    $outputtextbox.text="Validating information..."
    Start-Sleep -Seconds 1

    try {
        if((Test-FileLock -Path $healthPath )){
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $outputtextbox.text="Please wait..."
            Start-Sleep -Seconds 1
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and (![string]::IsNullOrEmpty($PasswordfileText.Text))){

            try {
                if((![string]::IsNullOrEmpty($UsernameTextbox.Text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.Text))){
                    $outputtextbox.text="Please wait..."
                    Start-Sleep -Seconds 1
                    throw
                }
                $messages=test-csv -path $PasswordfileText.Text
                if(!($messages)){
                    $outputtextbox.text="CSV is validated.."
                    Start-Sleep 2
                    Write-myLog -level INFO -messages "CSV validated"
                    Write-myLog -level INFO -messages "CSV file path : $($PasswordfileText.Text)"
                    $csvfile=import-csv -path $passwordfiletext.text | Sort-Object iloIP -Unique

                    $ProgressBar.Maximum=$csvfile.count
                    $ProgressBar.Value=0
                    $ProgressBar.Step=1
                    $OutputTextBox.Text="Please wait........."

                    $OutputTextBox.Text=("iLOIP"+","+"AgentlessManagementService"+","+"BatteryStatus"+","+"BIOSHardwareStatus"+","+`
                    "FanStatus"+","+"FanRedundancy"+","+"MemoryStatus"+","+"NetworkStatus"+","+"PowerSuppliesStatus"+","+"PowerSuppliesRedundancy"+","+`
                    "PowerSuppliesMismatch"+","+"ProcessorStatus"+","+"StorageStatus"+","+
                    "TemperatureStatus"+","+"Status"+","+"Issue"
                    )
                    $csvresults=foreach($item in $csvfile){
                        try{
                            $connection=connect-hpeilo $item.iloIP -username $item.username -password $item.password `
                            -warningaction ignore
                            $healthinfo=Get-HPEiLOHealthSummary -connection $connection
                            Write-myLog "Connection to $($item.iloIP) is secure"
                            $IP=$item.iloIP
                            $AMS=$healthinfo.AgentlessManagementService
                            $BatteryStatus=$healthinfo.BatteryStatus
                            $BHS=$healthinfo.BIOSHardwareStatus
                            $Fanstatus=$healthinfo.FanStatus
                            $fanredundancy=$healthinfo.FanRedundancy
                            $memorystatus=$healthinfo.MemoryStatus
                            $networkstatus=$healthinfo.NetworkStatus
                            $PSS=$healthinfo.PowerSuppliesStatus
                            $PSR=$healthinfo.PowerSuppliesRedundancy
                            $PSM=$healthinfo.PowerSuppliesMismatch
                            $Processorstatus=$healthinfo.ProcessorStatus
                            $storagestatus=$healthinfo.StorageStatus
                            $tempstatus=$healthinfo.TemperatureStatus
                            $status=$healthinfo.Status
                            $Issue="No Error"

                            $OutputTextBox.AppendText("`n")
                            $OutputTextBox.AppendText($item.iloIP+","+$healthinfo.AgentlessManagementService+","+$healthinfo.BatteryStatus+","+`
                            $healthinfo.BIOSHardwareStatus+","+$healthinfo.FanStatus+","+$healthinfo.FanRedundancy+","+$healthinfo.MemoryStatus+","+`
                            $healthinfo.NetworkStatus+","+$healthinfo.PowerSuppliesStatus+","+$healthinfo.PowerSuppliesRedundancy+","+`
                            $healthinfo.PowerSuppliesMismatch+","+$healthinfo.ProcessorStatus+","+$healthinfo.StorageStatus+","+`
                            $healthinfo.TemperatureStatus+","+$healthinfo.Status+","+$Issue)
                            $ProgressBar.PerformStep()
                        }
                        catch{
                            if($Error[0].Exception.Message -match  `
                            "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                            -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                try {
                                    $connection=connect-hpeilo $item.iloIP -username $item.username -password $item.password `
                                    -disablecertificateauthentication -warningaction ignore
                                    $healthinfo=Get-HPEiLOHealthSummary -connection $connection
                                    Write-myLog "Connection to $($item.iloIP) is unsecure"
                                    $IP=$item.iloIP
                                    $AMS=$healthinfo.AgentlessManagementService
                                    $BatteryStatus=$healthinfo.BatteryStatus
                                    $BHS=$healthinfo.BIOSHardwareStatus
                                    $Fanstatus=$healthinfo.FanStatus
                                    $fanredundancy=$healthinfo.FanRedundancy
                                    $memorystatus=$healthinfo.MemoryStatus
                                    $networkstatus=$healthinfo.NetworkStatus
                                    $PSS=$healthinfo.PowerSuppliesStatus
                                    $PSR=$healthinfo.PowerSuppliesRedundancy
                                    $PSM=$healthinfo.PowerSuppliesMismatch
                                    $Processorstatus=$healthinfo.ProcessorStatus
                                    $storagestatus=$healthinfo.StorageStatus
                                    $tempstatus=$healthinfo.TemperatureStatus
                                    $status=$healthinfo.Status
                                    $Issue="No Error"

                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($item.iloIP+","+$healthinfo.AgentlessManagementService+","+$healthinfo.BatteryStatus+","+`
                                    $healthinfo.BIOSHardwareStatus+","+$healthinfo.FanStatus+","+$healthinfo.FanRedundancy+","+$healthinfo.MemoryStatus+`
                                    ","+$healthinfo.NetworkStatus+","+$healthinfo.PowerSuppliesStatus+","+$healthinfo.PowerSuppliesRedundancy+","+`
                                    $healthinfo.PowerSuppliesMismatch+","+$healthinfo.ProcessorStatus+","+$healthinfo.StorageStatus+","+`
                                    $healthinfo.TemperatureStatus+","+$healthinfo.Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                                catch {
                                    $IP=$item.iloip
                                    $AMS="NA"
                                    $BatteryStatus="NA"
                                    $BHS="NA"
                                    $Fanstatus="NA"
                                    $fanredundancy="NA"
                                    $memorystatus="NA"
                                    $networkstatus="NA"
                                    $PSS="NA"
                                    $PSR="NA"
                                    $PSM="NA"
                                    $Processorstatus="NA"
                                    $storagestatus="NA"
                                    $tempstatus="NA"
                                    $status="NA"
                                    $Issue="$($error[0].Exception.Message)"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($item.iloIP+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+`
                                    "NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+$Error[0].exception.message)
                                    $ProgressBar.PerformStep()
                                }
                            }
                            else{
                                $IP=$item.iloip
                                $AMS="NA"
                                $BatteryStatus="NA"
                                $BHS="NA"
                                $Fanstatus="NA"
                                $fanredundancy="NA"
                                $memorystatus="NA"
                                $networkstatus="NA"
                                $PSS="NA"
                                $PSR="NA"
                                $PSM="NA"
                                $Processorstatus="NA"
                                $storagestatus="NA"
                                $tempstatus="NA"
                                $status="NA"
                                $Issue="$($error[0].Exception.Message)"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($item.iloIP+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+`
                                "NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+$Error[0].exception.message)
                                $ProgressBar.PerformStep()
                            }
                        }

                        [PSCustomObject]@{
                            'iLO IP'=$IP
                            'AgentlessManagementService'=$AMS
                            'BatteryStatus'=$BatteryStatus
                            'BIOSHardwareStatus'=$BHS
                            'FanStatus'=$Fanstatus
                            'FanRedundancy'=$fanredundancy
                            'MemoryStatus'=$memorystatus
                            'NetworkStatus'=$networkstatus
                            'PowerSuppliesStatus'=$PSS
                            'PowerSuppliesRedundancy'=$PSR
                            'PowerSuppliesMismatch'=$PSM
                            'ProcessorStatus'=$Processorstatus
                            'StorageStatus'=$storagestatus
                            'TemperatureStatus'=$tempstatus
                            'Status'=$Status
                            'Issue'=$Issue
                        }
                    }
                }
                else {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="CSV validation failed..."
                    Write-myLog -level ERROR -messages "CSV validation failed"
                    Write-myLog -level ERROR -messages $messages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $messages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
            catch {
                $ProgressBar.Value=0
                $outputtextbox.ForeColor="Red"
                $outputtextbox.text="You cannot define username or password with CSV file"
                Write-myLog -level ERROR -messages "User defined username or password with CSV file"
                Start-Sleep -Seconds 1
            }
        }
        else{
            try {

                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $outputtextbox.ForeColor="Black"
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((![string]::IsNullOrEmpty($FilePathTextBox.text))){
                    $ipvalidationmessages=test-iloIP -path $FilePathTextBox.Text
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$fileiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined text file with successful validation"
                    Write-myLog -level INFO -messages "Text file path : $($FilePathTextBox.Text)"
                }
                elseif(![string]::IsNullOrEmpty($iLOTextbox.text)){
                    $ipvalidationmessages=test-iloIpstring -IPs $textiloips
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$textiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined manual iLO IPs with successful validation"
                }

                $ProgressBar.Maximum=$iloIPs.count
                $ProgressBar.Value=0
                $ProgressBar.Step=1
                $outputtextbox.ForeColor="Black"
                $OutputTextBox.Text="Please wait........."
                $OutputTextBox.Text=("iLOIP"+","+"AgentlessManagementService"+","+"BatteryStatus"+","+"BIOSHardwareStatus"+","+`
                "FanStatus"+","+"FanRedundancy"+","+"MemoryStatus"+","+"NetworkStatus"+","+"PowerSuppliesStatus"+","+"PowerSuppliesRedundancy"+","+`
                "PowerSuppliesMismatch"+","+"ProcessorStatus"+","+"StorageStatus"+","+
                "TemperatureStatus"+","+"Status"+","+"Issue"
                )
                $csvresults=foreach($iloIP in $iloIPs){

                    try{
                        $connection=connect-hpeilo $iloIP -username $user -password $password `
                        -warningaction ignore
                        $healthinfo=Get-HPEiLOHealthSummary -connection $connection
                        Write-myLog -messages "Connection to $($iloIP) is secure"
                        $IP=$iloip
                        $AMS=$healthinfo.AgentlessManagementService
                        $BatteryStatus=$healthinfo.BatteryStatus
                        $BHS=$healthinfo.BIOSHardwareStatus
                        $Fanstatus=$healthinfo.FanStatus
                        $fanredundancy=$healthinfo.FanRedundancy
                        $memorystatus=$healthinfo.MemoryStatus
                        $networkstatus=$healthinfo.NetworkStatus
                        $PSS=$healthinfo.PowerSuppliesStatus
                        $PSR=$healthinfo.PowerSuppliesRedundancy
                        $PSM=$healthinfo.PowerSuppliesMismatch
                        $Processorstatus=$healthinfo.ProcessorStatus
                        $storagestatus=$healthinfo.StorageStatus
                        $tempstatus=$healthinfo.TemperatureStatus
                        $status=$healthinfo.Status
                        $Issue="No Error"

                        $OutputTextBox.AppendText("`n")
                        $OutputTextBox.AppendText($iloIP+","+$healthinfo.AgentlessManagementService+","+$healthinfo.BatteryStatus+","+`
                        $healthinfo.BIOSHardwareStatus+","+$healthinfo.FanStatus+","+$healthinfo.FanRedundancy+","+$healthinfo.MemoryStatus+","+`
                        $healthinfo.NetworkStatus+","+$healthinfo.PowerSuppliesStatus+","+$healthinfo.PowerSuppliesRedundancy+","+`
                        $healthinfo.PowerSuppliesMismatch+","+$healthinfo.ProcessorStatus+","+$healthinfo.StorageStatus+","+`
                        $healthinfo.TemperatureStatus+","+$healthinfo.Status+","+$Issue)
                        $ProgressBar.PerformStep()
                    }
                    catch{
                        if($Error[0].Exception.Message -match  `
                        "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                        -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                            try {
                                $connection=connect-hpeilo $iloIP -username $user -password $password -disablecertificateauthentication `
                                -warningaction ignore
                                $healthinfo=Get-HPEiLOHealthSummary -connection $connection
                                Write-myLog -messages "Connection to $($iloIP) is unsecure"
                                $IP=$iloip
                                $AMS=$healthinfo.AgentlessManagementService
                                $BatteryStatus=$healthinfo.BatteryStatus
                                $BHS=$healthinfo.BIOSHardwareStatus
                                $Fanstatus=$healthinfo.FanStatus
                                $fanredundancy=$healthinfo.FanRedundancy
                                $memorystatus=$healthinfo.MemoryStatus
                                $networkstatus=$healthinfo.NetworkStatus
                                $PSS=$healthinfo.PowerSuppliesStatus
                                $PSR=$healthinfo.PowerSuppliesRedundancy
                                $PSM=$healthinfo.PowerSuppliesMismatch
                                $Processorstatus=$healthinfo.ProcessorStatus
                                $storagestatus=$healthinfo.StorageStatus
                                $tempstatus=$healthinfo.TemperatureStatus
                                $status=$healthinfo.Status
                                $Issue="No Error"

                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($iloIP+","+$healthinfo.AgentlessManagementService+","+$healthinfo.BatteryStatus+","+`
                                $healthinfo.BIOSHardwareStatus+","+$healthinfo.FanStatus+","+$healthinfo.FanRedundancy+","+$healthinfo.MemoryStatus`
                                +","+$healthinfo.NetworkStatus+","+$healthinfo.PowerSuppliesStatus+","+$healthinfo.PowerSuppliesRedundancy+","+`
                                $healthinfo.PowerSuppliesMismatch+","+$healthinfo.ProcessorStatus+","+$healthinfo.StorageStatus+","+`
                                $healthinfo.TemperatureStatus+","+$healthinfo.Status+","+$Issue)

                                $ProgressBar.PerformStep()
                            }
                            catch {
                                $IP=$iloip
                                $AMS="NA"
                                $BatteryStatus="NA"
                                $BHS="NA"
                                $Fanstatus="NA"
                                $fanredundancy="NA"
                                $memorystatus="NA"
                                $networkstatus="NA"
                                $PSS="NA"
                                $PSR="NA"
                                $PSM="NA"
                                $Processorstatus="NA"
                                $storagestatus="NA"
                                $tempstatus="NA"
                                $status="NA"
                                $Issue="$($error[0].Exception.Message)"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($iloIP+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+`
                                "NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+$Error[0].exception.message)
                                $ProgressBar.PerformStep()
                            }
                        }
                        else{
                            $IP=$iloip
                            $AMS="NA"
                            $BatteryStatus="NA"
                            $BHS="NA"
                            $Fanstatus="NA"
                            $fanredundancy="NA"
                            $memorystatus="NA"
                            $networkstatus="NA"
                            $PSS="NA"
                            $PSR="NA"
                            $PSM="NA"
                            $Processorstatus="NA"
                            $storagestatus="NA"
                            $tempstatus="NA"
                            $status="NA"
                            $Issue="$($error[0].Exception.Message)"
                            $OutputTextBox.AppendText("`n")
                            $OutputTextBox.AppendText($iloIP+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+`
                            "NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+$Error[0].exception.message)
                            $ProgressBar.PerformStep()
                        }
                    }

                    [PSCustomObject]@{
                        'iLO IP'=$IP
                        'AgentlessManagementService'=$AMS
                        'BatteryStatus'=$BatteryStatus
                        'BIOSHardwareStatus'=$BHS
                        'FanStatus'=$Fanstatus
                        'FanRedundancy'=$fanredundancy
                        'MemoryStatus'=$memorystatus
                        'NetworkStatus'=$networkstatus
                        'PowerSuppliesStatus'=$PSS
                        'PowerSuppliesRedundancy'=$PSR
                        'PowerSuppliesMismatch'=$PSM
                        'ProcessorStatus'=$Processorstatus
                        'StorageStatus'=$storagestatus
                        'TemperatureStatus'=$tempstatus
                        'Status'=$Status
                        'Issue'=$Issue
                    }
                }
            }
            catch {
                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User defined multiple fields"
                    $Error.Clear()
                }

                elseif((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User didn't define any of the field along with username and password"
                    $Error.Clear()
                }
                elseif((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($ilotextbox.text))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs to continue.."
                    Write-myLog -level ERROR -messages "User defined ilo and text field both"
                    $Error.Clear()
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.Text="If you define iLO IPs or Text File field, you must define username and Password."
                    Write-myLog -level ERROR -messages "User didn't define Username or password with ilo IPs or text file"
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))) {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define only one field from Text file, ILO IPs or CSV file."
                    Write-myLog -level ERROR -messages "User defined multiple fields among text,iLOIPs and csv"
                    $Error.Clear()
                }
                else{
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    Write-myLog -level ERROR -messages "IP validation failed"
                    Write-myLog -level ERROR -messages $ipvalidationmessages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $ipvalidationmessages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
        }
        if($csvresults){
            $csvresults | Export-Csv -path $healthpath -NoTypeInformation -Force
            Write-myLog -level INFO -messages $csvresults
            if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
            if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
            if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
            if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
            if(![string]::IsNullOrEmpty($csvfile)){Clear-Variable -Name csvfile}
            if(![string]::IsNullOrEmpty($user)){Clear-Variable -Name user}
            if(![string]::IsNullOrEmpty($Password)){Clear-Variable -Name Password}
        }
    }
    catch {
        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $outputtextbox.text="Please define any one field out of ILO IPs, Text File or CSV file to continue"
            Write-myLog -level ERROR -messages "User didn't define any of the field"
        }
        elseif((Test-FileLock -Path $healthPath)){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="Please close the Healthinfo file to create a new one."
            Write-myLog -level ERROR -messages "user had the Healthinfo file open while new one was being created"
        }
        else {
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="some error happened, $($Error[0].exception.message)"
            Write-myLog -level ERROR -messages "some error happened, $($Error[0].exception.message)"
        }
    }
}
function imlButtonClick( $object ){
    Write-myLog -level INFO -messages "User clicked on IML Button"
    $ErrorActionPreference="stop"
    $outputtextbox.ForeColor="Black"
    $outputtextbox.text="Validating information..."
    Start-Sleep -Seconds 1

    try {
        if((Test-FileLock -Path $IMLPath)){
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $outputtextbox.text="Please wait..."
            Start-Sleep -Seconds 1
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and (![string]::IsNullOrEmpty($PasswordfileText.Text))){

            try {
                if((![string]::IsNullOrEmpty($UsernameTextbox.Text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.Text))){
                    $outputtextbox.text="Please wait..."
                    Start-Sleep -Seconds 1
                    throw
                }
                $messages=test-csv -path $PasswordfileText.Text

                if(!($messages)){

                    $outputtextbox.text="CSV is validated.."
                    Start-Sleep 2
                    Write-myLog -level INFO -messages "CSV validated"
                    Write-myLog -level INFO -messages "CSV file path : $($PasswordfileText.Text)"
                    $csvfile=import-csv -path $passwordfiletext.text  | Sort-Object iloIP -Unique

                    $ProgressBar.Maximum=$csvfile.count
                    $ProgressBar.Value=0
                    $ProgressBar.Step=1
                    $OutputTextBox.Text="Please wait........."

                    $OutputTextBox.Text="Please wait, do not close or reset the tool...."
                    $csvresults=
                    foreach($item in $csvfile) {
                        try {
                            $ErrorActionPreference="Stop"
                            $connection=Connect-HPEiLO $Item.iloip -Username $Item.Username -Password $Item.Password `
                            -warningaction Ignore
                            $obj=Get-hpeiloiml -Connection $connection
                            $iml_logs=$obj.imllog
                            Write-myLog -messages "Connection to $($item.iloip) is secure"

                            $imllogs=For($i=0;$i -lt $iml_logs.count;$i++){
                                [PSCustomObject]@{
                                    'iLO IP'=$_.iloip
                                    'ID'=$iml_logs[$i].ID
                                    'Name'=$iml_logs[$i].Name
                                    #'Categories'=$iml_logs[$i].Categories
                                    'EntryType'=$iml_logs[$i].EntryType
                                    'EventNumber'=$iml_logs[$i].EventNumber
                                    'OEMRecordFormat'=$iml_logs[$i].OEMRecordFormat
                                    'LearnMorelink'=$iml_logs[$i].LearnMorelink
                                    'RecommendedAction'=$iml_logs[$i].RecommendedAction
                                    'Repaired'=$iml_logs[$i].Repaired
                                    'Count'=$iml_logs[$i].count
                                    'Created'=$iml_logs[$i].Created
                                    'EventCode'=$iml_logs[$i].EventCode
                                    'Class'=$iml_logs[$i].Class
                                    'Message'=$iml_logs[$i].message
                                    'Severity'=$iml_logs[$i].Severity
                                    'Updated'=$iml_logs[$i].Updated
                                }
                            }
                            $imllogs | Export-Csv -NoTypeInformation -Path $filedirectory\$($item.iloIP)_imlLogs.csv -Force -Delimiter ","

                            $Status="Success"
                            $Issue="No Error"
                        }
                        catch {
                            if($Error[0].Exception.Message -match  `
                            "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                            -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                                try {
                                    $ErrorActionPreference="Stop"
                                    $connection=Connect-HPEiLO $Item.iloip -Username $Item.Username -Password $Item.Password `
                                    -DisableCertificateAuthentication -warningaction Ignore
                                    $obj=Get-hpeiloiml -Connection $connection
                                    Write-myLog -messages "Connection to $($item.iloip) is unsecure"
                                    $iml_logs=$obj.imllog

                                    $imllogs=For($i=0;$i -lt $iml_logs.count;$i++){
                                        [PSCustomObject]@{
                                            'iLO IP'=$_.iloip
                                        'ID'=$iml_logs[$i].ID
                                        'Name'=$iml_logs[$i].Name
                                        #'Categories'=$iml_logs[$i].Categories
                                        'EntryType'=$iml_logs[$i].EntryType
                                        'EventNumber'=$iml_logs[$i].EventNumber
                                        'OEMRecordFormat'=$iml_logs[$i].OEMRecordFormat
                                        'LearnMorelink'=$iml_logs[$i].LearnMorelink
                                        'RecommendedAction'=$iml_logs[$i].RecommendedAction
                                        'Repaired'=$iml_logs[$i].Repaired
                                        'Count'=$iml_logs[$i].count
                                        'Created'=$iml_logs[$i].Created
                                        'EventCode'=$iml_logs[$i].EventCode
                                        'Class'=$iml_logs[$i].Class
                                        'Message'=$iml_logs[$i].message
                                        'Severity'=$iml_logs[$i].Severity
                                        'Updated'=$iml_logs[$i].Updated
                                    }
                                }
                                    $imllogs | Export-Csv -NoTypeInformation -Path $filedirectory\$($item.iloIP)_imlLogs.csv -Force -Delimiter ","

                                    $Status="Success"
                                    $Issue="No Error"
                                }
                                catch {
                                    $Status="Failure"
                                    $Issue=$($Error[0].Exception.Message)
                                }
                            }
                            else{
                                $Status="Failure"
                                $Issue=$($Error[0].Exception.Message)
                            }
                        }
                        [PSCustomObject]@{
                            'iLO IP'=$Item.iloIP
                            'IML Download Status'=$Status
                            'Error'=$Issue
                        }
                    }
                    $outputtextbox.ForeColor="Green"
                    $OutputTextBox.Text="Please check the IML files generated to verify status of IML logs..."
                    Write-myLog -level ERROR -messages "IMLINFO file generated"
                }
                else {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="CSV validation failed..."
                    Write-myLog -level ERROR -messages "CSV validation failed"
                    Write-myLog -level ERROR -messages $messages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $messages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
            catch {
                $ProgressBar.Value=0
                $outputtextbox.ForeColor="Red"
                $outputtextbox.text="You cannot define username or password with CSV file.."
                Write-myLog -level ERROR -messages "User defined username or password with CSV file"
                Start-Sleep -Seconds 1
            }
        }
        else{
            try {

                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $outputtextbox.ForeColor="Black"
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((![string]::IsNullOrEmpty($FilePathTextBox.text))){
                    $ipvalidationmessages=test-iloIP -path $FilePathTextBox.Text
                    if($ipvalidationmessages){
                          throw
                    }
                    $iloIPs=$fileiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined text file with successful validation"
                    Write-myLog -level INFO -messages "Text file path : $($FilePathTextBox.Text)"
                }
                elseif(![string]::IsNullOrEmpty($iLOTextbox.text)){
                    $ipvalidationmessages=test-iloIpstring -IPs $textiloips
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$textiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined manual iLO IPs with successful validation"
                }
                $ProgressBar.Maximum=$iloIPs.count
                $ProgressBar.Value=0
                $ProgressBar.Step=1
                $outputtextbox.ForeColor="Black"
                $OutputTextBox.Text="Please wait, do not close or reset the tool..."
                $csvresults=
                    foreach($iloip in $iloIPs) {
                        try {
                            $ErrorActionPreference="Stop"
                            $connection=Connect-HPEiLO $iloip -Username $User -Password $Password `
                            -warningaction Ignore
                            $obj=Get-hpeiloiml -Connection $connection
                            Write-myLog -messages "Connection to $($iloip) is secure"
                            $iml_logs=$obj.imllog

                            $imllogs=For($i=0;$i -lt $iml_logs.count;$i++){
                                [PSCustomObject]@{
                                    'iLO IP'=$iloip
                                    'ID'=$iml_logs[$i].ID
                                    'Name'=$iml_logs[$i].Name
                                    #'Categories'=$iml_logs[$i].Categories
                                    'EntryType'=$iml_logs[$i].EntryType
                                    'EventNumber'=[string]$iml_logs[$i].EventNumber
                                    'OEMRecordFormat'=$iml_logs[$i].OEMRecordFormat
                                    'LearnMorelink'=$iml_logs[$i].LearnMorelink
                                    'RecommendedAction'=$iml_logs[$i].RecommendedAction
                                    'Repaired'=$iml_logs[$i].Repaired
                                    'Count'=$iml_logs[$i].count
                                    'Created'=$iml_logs[$i].Created
                                    'EventCode'=$iml_logs[$i].EventCode
                                    'Class'=$iml_logs[$i].Class
                                    'Message'=$iml_logs[$i].message
                                    'Severity'=$iml_logs[$i].Severity
                                    'Updated'=$iml_logs[$i].Updated
                                }
                            }
                            $imllogs | Export-Csv -NoTypeInformation -Path $filedirectory\$($iloip)_imlLogs.csv -Force -Delimiter ","

                            $Status="Success"
                            $Issue="No Error"
                        }
                        catch {
                            if($Error[0].Exception.Message -match  `
                            "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                            -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception" ){
                                try {
                                    $ErrorActionPreference="Stop"
                                    $connection=Connect-HPEiLO $iloip -Username $User -Password $Password `
                                    -DisableCertificateAuthentication -warningaction Ignore
                                    $obj=Get-hpeiloiml -Connection $connection
                                    $iml_logs=$obj.imllog
                                    Write-myLog -messages "Connection to $($iloip) is unsecure"
                                    $imllogs=For($i=0;$i -lt $iml_logs.count;$i++){
                                        [PSCustomObject]@{
                                            'iLO IP'=$iloip
                                            'ID'=$iml_logs[$i].ID
                                            'Name'=$iml_logs[$i].Name
                                            #'Categories'=$iml_logs[$i].Categories
                                            'EntryType'=$iml_logs[$i].EntryType
                                            'EventNumber'=[string]$iml_logs[$i].EventNumber
                                            'OEMRecordFormat'=$iml_logs[$i].OEMRecordFormat
                                            'LearnMorelink'=$iml_logs[$i].LearnMorelink
                                            'RecommendedAction'=$iml_logs[$i].RecommendedAction
                                            'Repaired'=$iml_logs[$i].Repaired
                                            'Count'=$iml_logs[$i].count
                                            'Created'=$iml_logs[$i].Created
                                            'EventCode'=$iml_logs[$i].EventCode
                                            'Class'=$iml_logs[$i].Class
                                            'Message'=$iml_logs[$i].message
                                            'Severity'=$iml_logs[$i].Severity
                                            'Updated'=$iml_logs[$i].Updated
                                        }
                                    }
                                    $imllogs | Export-Csv -NoTypeInformation -Path $filedirectory\$($iloip)_imlLogs.csv -Force -Delimiter ","

                                    $Status="Success"
                                    $Issue="No Error"
                                }
                                catch {
                                    $Status="Failure"
                                    $Issue=$($Error[0].Exception.Message)
                                }
                            }
                            else{
                                $Status="Failure"
                                $Issue=$($Error[0].Exception.Message)
                            }
                        }
                        [PSCustomObject]@{
                            'iLO IP'=$iloip
                            'IML Download Status'=$Status
                            'Error'=$Issue
                        }
                    }
                $outputtextbox.ForeColor="Green"
                $OutputTextBox.Text="Please check the IML files generated to verify status of IML logs..."
                Write-myLog -level INFO -messages "IMLINFO file generated"
            }
            catch {
                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User defined multiple fields"
                    $Error.Clear()
                }

                elseif((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User didn't define any of the field along with username and password"
                    $Error.Clear()
                }
                elseif((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($ilotextbox.text))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs to continue.."
                    Write-myLog -level ERROR -messages "User defined ilo and text field both"
                    $Error.Clear()
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.Text="If you define iLO IPs or Text File field, you must define username and Password."
                    Write-myLog -level ERROR -messages "User didn't define Username or password with ilo IPs or text file"
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))) {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define only one field from Text file, ILO IPs or CSV file."
                    Write-myLog -level ERROR -messages "User defined multiple fields among text,iLOIPs and csv"
                    $Error.Clear()
                }
                else{
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="IP validation failed..."
                    Write-myLog -level ERROR -messages "IP validation failed"
                    Write-myLog -level ERROR -messages $ipvalidationmessages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $ipvalidationmessages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
        }
        if($csvresults){
            $csvresults | Export-Csv -path $IMLPath -NoTypeInformation -Force
            Write-myLog -level INFO -messages $csvresults
            if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
            if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
            if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
            if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
            if(![string]::IsNullOrEmpty($csvfile)){Clear-Variable -Name csvfile}
            if(![string]::IsNullOrEmpty($user)){Clear-Variable -Name user}
            if(![string]::IsNullOrEmpty($Password)){Clear-Variable -Name Password}
        }
    }
    catch {
        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $outputtextbox.text="Please define any one field out of ILO IPs, Text File or CSV file to continue"
            Write-myLog -level ERROR -messages "User didn't define any of the field"
        }
        elseif((Test-FileLock -Path $IMLPath)){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="Please close the IMLinfo file to create a new one."
            Write-myLog -level ERROR -messages "user had the IMLinfo file open while new one was being created"
        }
        else {
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="some error happened, $($Error[0].exception.message)"
            write-mylog -level ERROR -messages "some error happened, $($Error[0].exception.message)"
        }
    }
}

function ProgressBarClick( $object ){

}

function FirmwareButtonClick( $object ){
    Write-myLog -level INFO -messages "User clicked on Firmware Button"
    $ErrorActionPreference="stop"
    $outputtextbox.ForeColor="Black"
    $outputtextbox.text="Validating information..."
    Start-Sleep -Seconds 1

    try {
        if((Test-FileLock -Path $firmwarePath)){
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $outputtextbox.text="Please wait..."
            Start-Sleep -Seconds 1
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and (![string]::IsNullOrEmpty($PasswordfileText.Text))){

            try {
                if((![string]::IsNullOrEmpty($UsernameTextbox.Text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.Text))){
                    $outputtextbox.text="Please wait..."
                    Start-Sleep -Seconds 1
                    throw
                }
                $messages=test-csv -path $PasswordfileText.Text

                if(!($messages)){

                    $outputtextbox.text="CSV is validated.."
                    Start-Sleep 2
                    Write-myLog -level INFO -messages "CSV validated"
                    Write-myLog -level INFO -messages "CSV file path : $($PasswordfileText.Text)"
                    $csvfile=import-csv -path $passwordfiletext.text | Sort-Object iloIP -Unique

                    $ProgressBar.Maximum=$csvfile.count
                    $ProgressBar.Value=0
                    $ProgressBar.Step=1
                    $OutputTextBox.Text="Please wait........."

                    $OutputTextBox.Text=("iLOIP"+","+"Index"+","+"Firmware Name"+","+"Firmware Version"+","+"Device Class"+","+"Location"+","+"Error")

                    $csvresults=
                    foreach($item in $csvfile){
                        try {
                            $connection=Connect-HPEiLO $item.iloip -Username $item.Username -Password $item.Password `
                            -warningaction Ignore
                            $obj=Get-HPEiLOFirmwareInventory -Connection $connection
                            Write-myLog -messages "Connection to $($item.iloIP) is secure"
                            $firmwareinfo=$obj.firmwareinformation
                            For($i=0;$i -lt $firmwareinfo.count;$i++){
                                [PSCustomObject]@{
                                    'iLO IP'=$item.iloip
                                    'Index' = $firmwareinfo[$i].Index
                                    'Firmware Name'=$firmwareinfo[$i].firmwarename
                                    'Firmware Version'=$firmwareinfo[$i].firmwareversion
                                    'Device Class'=$firmwareinfo[$i].deviceclass
                                    'Location'=$firmwareinfo[$i].Location
                                    'Issue'="No Error"
                                }
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($item.iloIP+","+$firmwareinfo[$i].Index+","+$firmwareinfo[$i].firmwarename+","+`
                                $firmwareinfo[$i].firmwareversion+","+$firmwareinfo[$i].deviceclass+","+$firmwareinfo[$i].Location+","+"no error")
                                $ProgressBar.PerformStep()
                            }
                        }
                        catch {
                            if($Error[0].Exception.Message -match  `
                                "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                -or $Error[0].Exception.Message -match  `
                                "The SSL connection could not be established, see inner exception" ){
                                try {
                                    $connection=Connect-HPEiLO $item.iloip -Username $item.Username -Password $item.Password `
                                    -DisableCertificateAuthentication -warningaction Ignore
                                    $obj=Get-HPEiLOFirmwareInventory -Connection $connection
                                    Write-myLog -messages "Connection to $($item.iloIP) is unsecure"
                                    $firmwareinfo=$obj.firmwareinformation
                                    For($i=0;$i -lt $firmwareinfo.count;$i++){
                                        [PSCustomObject]@{
                                        'iLO IP'=$item.iloip
                                        'Index' = $firmwareinfo[$i].Index
                                        'Firmware Name'=$firmwareinfo[$i].firmwarename
                                        'Firmware Version'=$firmwareinfo[$i].firmwareversion
                                        'Device Class'=$firmwareinfo[$i].deviceclass
                                        'Location'=$firmwareinfo[$i].Location
                                        'Issue'="No Error"
                                        }
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($item.iloIP+","+$firmwareinfo[$i].Index+","+$firmwareinfo[$i].firmwarename+","+`
                                        $firmwareinfo[$i].firmwareversion+","+$firmwareinfo[$i].deviceclass+","+$firmwareinfo[$i].Location+","+"no error")
                                        $ProgressBar.PerformStep()
                                    }
                                }
                                catch {
                                    [PSCustomObject]@{
                                        'iLO IP'=$item.iloip
                                        'Index' = "NA"
                                        'Firmware Name'="NA"
                                        'Firmware Version'="NA"
                                        'Device Class'="NA"
                                        'Location'="NA"
                                        'Issue'=$($error[0].Exception.Message)
                                    }
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($item.iloIP+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+$($error[0].Exception.Message))
                                    $ProgressBar.PerformStep()
                                }
                            }
                            else{
                                [PSCustomObject]@{
                                    'iLO IP'=$item.iloip
                                    'Index' = "NA"
                                    'Firmware Name'="NA"
                                    'Firmware Version'="NA"
                                    'Device Class'="NA"
                                    'Location'="NA"
                                    'Issue'=$($error[0].Exception.Message)
                                }
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($item.iloIP+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+$($error[0].Exception.Message))
                                $ProgressBar.PerformStep()
                            }
                        }
                    }
                }
                else {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="CSV validation failed..."
                    Write-myLog -level ERROR -messages "CSV validation failed"
                    Write-myLog -level ERROR -messages $messages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $messages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
            catch {
                $ProgressBar.Value=0
                $outputtextbox.ForeColor="Red"
                $outputtextbox.text="You cannot define username or password with CSV file"
                Write-myLog -level ERROR -messages "User defined username or password with CSV file"
                Start-Sleep -Seconds 1
            }
        }
        else{
            try {

                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $outputtextbox.ForeColor="Black"
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((![string]::IsNullOrEmpty($FilePathTextBox.text))){
                    $ipvalidationmessages=test-iloIP -path $FilePathTextBox.Text
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$fileiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined text file with successful validation"
                    Write-myLog -level INFO -messages "Text file path : $($FilePathTextBox.Text)"
                }
                elseif(![string]::IsNullOrEmpty($iLOTextbox.text)){
                    $ipvalidationmessages=test-iloIpstring -IPs $textiloips
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$textiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined manual iLO IPs with successful validation"
                }

                $ProgressBar.Maximum=$iloIPs.count
                $ProgressBar.Value=0
                $ProgressBar.Step=1
                $outputtextbox.ForeColor="Black"
                $OutputTextBox.Text="Please wait........."

                $OutputTextBox.Text=("iLOIP"+","+"Index"+","+"Firmware Name"+","+"Firmware Version"+","+"Device Class"+","+"Location"+","+"Error")

                $csvresults=
                    foreach($iloip in $iloips){
                        try {
                            $connection=Connect-HPEiLO $iloip -Username $user -Password $Password -DisableCertificateAuthentication `
                            -warningaction Ignore
                            $obj=Get-HPEiLOFirmwareInventory -Connection $connection
                            Write-myLog -messages "Connection to $($iloIP) is secure"
                            $firmwareinfo=$obj.firmwareinformation
                            For($i=0;$i -lt $firmwareinfo.count;$i++){
                                [PSCustomObject]@{
                                    'iLO IP'=$iloip
                                    'Index' = $firmwareinfo[$i].Index
                                    'Firmware Name'=$firmwareinfo[$i].firmwarename
                                    'Firmware Version'=$firmwareinfo[$i].firmwareversion
                                    'Device Class'=$firmwareinfo[$i].deviceclass
                                    'Location'=$firmwareinfo[$i].Location
                                    'Issue'="No Error"
                                }
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($iloIP+","+$firmwareinfo[$i].Index+","+$firmwareinfo[$i].firmwarename+","+`
                                $firmwareinfo[$i].firmwareversion+","+$firmwareinfo[$i].deviceclass+","+$firmwareinfo[$i].Location+","+"no error")
                                $ProgressBar.PerformStep()
                            }
                        }
                        catch {
                            if($Error[0].Exception.Message -match  `
                                "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                -or $Error[0].Exception.Message -match  `
                                "The SSL connection could not be established, see inner exception"){
                                try{
                                    $connection=Connect-HPEiLO $iloip -Username $user -Password $Password -DisableCertificateAuthentication `
                                    -warningaction Ignore
                                    $obj=Get-HPEiLOFirmwareInventory -Connection $connection
                                    Write-myLog -messages "Connection to $($iloIP) is unsecure"
                                    $firmwareinfo=$obj.firmwareinformation
                                    For($i=0;$i -lt $firmwareinfo.count;$i++){
                                        [PSCustomObject]@{
                                            'iLO IP'=$iloip
                                            'Index' = $firmwareinfo[$i].Index
                                            'Firmware Name'=$firmwareinfo[$i].firmwarename
                                            'Firmware Version'=$firmwareinfo[$i].firmwareversion
                                            'Device Class'=$firmwareinfo[$i].deviceclass
                                            'Location'=$firmwareinfo[$i].Location
                                            'Issue'="No Error"
                                        }
                                        $OutputTextBox.AppendText("`n")
                                        $OutputTextBox.AppendText($iloIP+","+$firmwareinfo[$i].Index+","+$firmwareinfo[$i].firmwarename+","+`
                                        $firmwareinfo[$i].firmwareversion+","+$firmwareinfo[$i].deviceclass+","+$firmwareinfo[$i].Location+","+"no error")
                                        $ProgressBar.PerformStep()
                                    }
                                }
                                catch{
                                    [PSCustomObject]@{
                                        'iLO IP'=$iloip
                                        'Index' = "NA"
                                        'Firmware Name'="NA"
                                        'Firmware Version'="NA"
                                        'Device Class'="NA"
                                        'Location'="NA"
                                        'Issue'=$($error[0].Exception.Message)
                                    }
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($iloIP+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+$($error[0].Exception.Message))
                                    $ProgressBar.PerformStep()
                                }
                            }
                            else{
                                [PSCustomObject]@{
                                    'iLO IP'=$iloip
                                    'Index' = "NA"
                                    'Firmware Name'="NA"
                                    'Firmware Version'="NA"
                                    'Device Class'="NA"
                                    'Location'="NA"
                                    'Issue'=$($error[0].Exception.Message)
                                }
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($iloIP+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+"NA"+","+$($error[0].Exception.Message))
                                $ProgressBar.PerformStep()
                            }
                        }
                    }
            }
            catch {
                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User defined multiple fields"
                    $Error.Clear()
                }

                elseif((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User didn't define any of the field along with username and password"
                    $Error.Clear()
                }
                elseif((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($ilotextbox.text))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs to continue.."
                    Write-myLog -level ERROR -messages "User defined ilo and text field both"
                    $Error.Clear()
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.Text="If you define iLO IPs or Text File field, you must define username and Password."
                    Write-myLog -level ERROR -messages "User didn't define Username or password with ilo IPs or text file"
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))) {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define only one field from Text file, ILO IPs or CSV file."
                    Write-myLog -level ERROR -messages "User defined multiple fields among text,iLOIPs and csv"
                    $Error.Clear()
                }
                else{
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="IP validation failed..."
                    Write-myLog -level ERROR -messages "IP validation failed"
                    Write-myLog -level ERROR -messages $ipvalidationmessages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $ipvalidationmessages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
        }
        if($csvresults){
            $csvresults | Export-Csv -path $firmwarepath -NoTypeInformation -Force
            Write-myLog -level INFO -messages $csvresults
            if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
            if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
            if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
            if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
            if(![string]::IsNullOrEmpty($csvfile)){Clear-Variable -Name csvfile}
            if(![string]::IsNullOrEmpty($user)){Clear-Variable -Name user}
            if(![string]::IsNullOrEmpty($Password)){Clear-Variable -Name Password}
        }
    }
    catch {
        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $outputtextbox.text="Please define any one field out of ILO IPs, Text File or CSV file to continue"
            Write-myLog -level ERROR -messages "User didn't define any of the field"
        }
        elseif((Test-FileLock -Path $firmwarePath)){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="Please close the Firmwareinfo file to create a new one."
            Write-myLog -level ERROR -messages "user had the Firmwareinfo file open while new one was being created"
        }
        else {
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="some error happened, $($Error[0].exception.message)"
            Write-myLog -level ERROR -messages "some error happened, $($Error[0].exception.message)"
        }
    }
}

function UptimeButtonClick( $object ){
    Write-myLog -level INFO -messages "User clicked on Uptime Button"
    $ErrorActionPreference="stop"
    $outputtextbox.ForeColor="Black"
    $outputtextbox.text="Validating information..."
    Start-Sleep -Seconds 1

    try {
        if((Test-FileLock -Path $uptimePath )){
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $outputtextbox.text="Please wait..."
            Start-Sleep -Seconds 1
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and (![string]::IsNullOrEmpty($PasswordfileText.Text))){

            try {
                if((![string]::IsNullOrEmpty($UsernameTextbox.Text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.Text))){
                    $outputtextbox.text="Please wait..."
                    Start-Sleep -Seconds 1
                    throw
                }
                $messages=test-csv -path $PasswordfileText.Text

                if(!($messages)){

                    $outputtextbox.text="CSV is validated.."
                    Start-Sleep 2
                    Write-myLog -level INFO -messages "CSV validated"
                    Write-myLog -level INFO -messages "CSV file path : $($PasswordfileText.Text)"
                    $csvfile=import-csv -path $passwordfiletext.text | Sort-Object iloIP -Unique

                    $ProgressBar.Maximum=$csvfile.count
                    $ProgressBar.Value=0
                    $ProgressBar.Step=1
                    $OutputTextBox.Text="Please wait........."

                    $OutputTextBox.Text=("iLOIP"+","+"Uptime"+","+"Status"+","+"Issue")

                    $csvresults=foreach($item in $csvfile){

                        try{
                            $connection=connect-hpeilo $item.iloIP -username $item.username -password $item.password `
                            -warningaction ignore
                            $Powerontimeinfo=get-hpeilopowerontime -connection $connection
                            $uptime=(get-date).addminutes(-$($Powerontime.Poweronminutes))
                            Write-myLog -messages "Connection to $($item.iloIP) is secure"

                            $IP=$item.iloIP
                            $Upsince=$uptime
                            $status=$Powerontimeinfo.Status
                            $Issue="No Error"
                            $OutputTextBox.AppendText("`n")
                            $OutputTextBox.AppendText($item.iloIP+","+$uptime+","+$Powerontimeinfo.Status+","+$Issue)
                            $ProgressBar.PerformStep()
                        }
                        catch{

                            if($Error[0].Exception.Message -match  `
                                "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                -or $Error[0].Exception.Message -match  `
                                "The SSL connection could not be established, see inner exception" ){
                                try {
                                    $connection=connect-hpeilo $item.iloIP -username $item.username -password $item.password `
                                    -disablecertificateauthentication -warningaction ignore
                                    $Powerontimeinfo=get-hpeilopowerontime -connection $connection
                                    $uptime=(get-date).addminutes(-$($Powerontime.Poweronminutes))
                                    Write-myLog -messages "Connection to $($item.iloIP) is unsecure"

                                    $IP=$item.iloIP
                                    $Upsince=$uptime
                                    $status=$Powerontimeinfo.Status
                                    $Issue="No Error"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($item.iloIP+","+$uptime+","+$Powerontimeinfo.Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                                catch {
                                    $OutputTextBox.AppendText("`n")
                                    $uptime="NA"
                                    $status="Failure"
                                    $Issue="$($error[0].Exception.Message)"
                                    $OutputTextBox.AppendText($item.iloIP+","+$uptime+","+$Status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                            }
                            else{
                                $OutputTextBox.AppendText("`n")
                                $uptime="NA"
                                $status="Failure"
                                $Issue="$($error[0].Exception.Message)"
                                $OutputTextBox.AppendText($item.iloIP+","+$uptime+","+$Status+","+$Issue)
                                $ProgressBar.PerformStep()
                            }
                        }

                        [PSCustomObject]@{
                            'iLO IP'=$IP
                            'Uptime'=$Upsince
                            'Status'=$Status
                            'Issue'=$Issue
                        }
                    }
                }
                else {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="CSV validation failed..."
                    Write-myLog -level ERROR -messages "CSV validation failed"
                    Write-myLog -level ERROR -messages $messages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $messages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
            catch {
                $ProgressBar.Value=0
                $outputtextbox.ForeColor="Red"
                $outputtextbox.text="You cannot define username or password with CSV file"
                Write-myLog -level ERROR -messages "User defined username or password with CSV file"
                Start-Sleep -Seconds 1
            }
        }
        else{
            try {

                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $outputtextbox.ForeColor="Black"
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((![string]::IsNullOrEmpty($FilePathTextBox.text))){
                    $ipvalidationmessages=test-iloIP -path $FilePathTextBox.Text
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$fileiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined text file with successful validation"
                    Write-myLog -level INFO -messages "Text file path : $($FilePathTextBox.Text)"
                }
                elseif(![string]::IsNullOrEmpty($iLOTextbox.text)){
                    $ipvalidationmessages=test-iloIpstring -IPs $textiloips
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$textiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined manual iLO IPs with successful validation"
                }

                $ProgressBar.Maximum=$iloIPs.count
                $ProgressBar.Value=0
                $ProgressBar.Step=1
                $outputtextbox.ForeColor="Black"
                $OutputTextBox.Text="Please wait........."

                $OutputTextBox.Text=("iLOIP"+","+"Uptime"+","+"Status"+","+"Issue")

                $csvresults=foreach($iloIP in $iloIPs){

                    try{

                        $connection=connect-hpeilo $iloIP -username $user -password $password `
                        -warningaction ignore
                        $Powerontimeinfo=get-hpeilopowerontime -connection $connection
                        $uptime=(get-date).addminutes(-$($Powerontime.Poweronminutes))
                        Write-myLog -messages "Connection to $($iloIP) is secure"

                        $IP=$iloip
                        $Upsince=$uptime
                        $status=$Powerontimeinfo.Status
                        $Issue="No Error"
                        $OutputTextBox.AppendText("`n")
                        $OutputTextBox.AppendText($iloIP+","+$uptime+","+$Powerontimeinfo.Status+","+$Issue)
                        $ProgressBar.PerformStep()
                    }
                    catch{
                        if($Error[0].Exception.Message -match  `
                            "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                            -or $Error[0].Exception.Message -match  `
                            "The SSL connection could not be established, see inner exception" ){
                            try {
                                $connection=connect-hpeilo $iloIP -username $user -password $password `
                                -disablecertificateauthentication -warningaction ignore
                                $Powerontimeinfo=get-hpeilopowerontime -connection $connection
                                $uptime=(get-date).addminutes(-$($Powerontime.Poweronminutes))
                                Write-myLog -messages "Connection to $($iloIP) is unsecure"
                                $IP=$iloIP
                                $Upsince=$uptime
                                $status=$Powerontimeinfo.Status
                                $Issue="No Error"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($iloIP+","+$uptime+","+$Powerontimeinfo.Status+","+$Issue)
                                $ProgressBar.PerformStep()
                            }
                            catch {
                                $OutputTextBox.AppendText("`n")
                                $uptime="NA"
                                $status="Failure"
                                $Issue="$($error[0].Exception.Message)"
                                $OutputTextBox.AppendText($iloIP+","+$uptime+","+$status+","+$Issue)
                                $ProgressBar.PerformStep()
                            }
                        }
                        else{
                            $OutputTextBox.AppendText("`n")
                            $uptime="NA"
                            $status="Failure"
                            $Issue="$($error[0].Exception.Message)"
                            $OutputTextBox.AppendText($iloIP+","+$uptime+","+$status+","+$Issue)
                            $ProgressBar.PerformStep()
                        }
                    }
                    [PSCustomObject]@{
                        'iLO IP'=$IP
                        'Uptime'=$Upsince
                        'Status'=$Status
                        'Issue'=$Issue
                    }
                }
            }
            catch {
                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User defined multiple fields"
                    $Error.Clear()
                }

                elseif((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User didn't define any of the field along with username and password"
                    $Error.Clear()
                }
                elseif((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($ilotextbox.text))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs to continue.."
                    Write-myLog -level ERROR -messages "User defined ilo and text field both"
                    $Error.Clear()
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.Text="If you define iLO IPs or Text File field, you must define username and Password."
                    Write-myLog -level ERROR -messages "User didn't define Username or password with ilo IPs or text file"
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))) {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define only one field from Text file, ILO IPs or CSV file."
                    Write-myLog -level ERROR -messages "User defined multiple fields among text,iLOIPs and csv"
                    $Error.Clear()
                }
                else{
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="IP validation failed..."
                    Write-myLog -level ERROR -messages "IP validation failed"
                    Write-myLog -level ERROR -messages $ipvalidationmessages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $ipvalidationmessages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
        }
        if($csvresults){
            $csvresults | Export-Csv -path $uptimepath -NoTypeInformation -Force
            Write-myLog -level INFO -messages $csvresults
            if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
            if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
            if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
            if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
            if(![string]::IsNullOrEmpty($csvfile)){Clear-Variable -Name csvfile}
            if(![string]::IsNullOrEmpty($user)){Clear-Variable -Name user}
            if(![string]::IsNullOrEmpty($Password)){Clear-Variable -Name Password}
        }
    }
    catch {
        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $outputtextbox.text="Please define any one field out of ILO IPs, Text File or CSV file to continue"
            Write-myLog -level ERROR -messages "User didn't define any of the field"
        }
        elseif((Test-FileLock -Path $uptimePath)){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="Please close the Uptimeinfo file to create a new one."
            Write-myLog -level ERROR -messages "user had the Uptimeinfo file open while new one was being created"
        }
        else {
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="some error happened, $($Error[0].exception.message)"
            Write-myLog -level ERROR -messages "some error happened, $($Error[0].exception.message)"
        }
    }
}

function AHSButtonClick( $object ){
    Write-myLog -level INFO -messages "User clicked on AHS Button"
    $ErrorActionPreference="stop"
    $outputtextbox.ForeColor="Black"
    $outputtextbox.text="Validating information..."
    Start-Sleep -Seconds 1

    try {
        if((Test-FileLock -Path $ahsPath)){
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $outputtextbox.text="Please wait..."
            Start-Sleep -Seconds 1
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and (![string]::IsNullOrEmpty($PasswordfileText.Text))){

            try {
                if((![string]::IsNullOrEmpty($UsernameTextbox.Text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.Text))){
                    $outputtextbox.text="Please wait..."
                    Start-Sleep -Seconds 1
                    throw
                }
                $messages=test-csv -path $PasswordfileText.Text

                if(!($messages)){

                    $outputtextbox.text="CSV is validated.."
                    Write-myLog -level INFO -messages "CSV validated"
                    Write-myLog -level INFO -messages "CSV file path : $($PasswordfileText.Text)"
                    Start-Sleep 2

                    $csvfile=import-csv -path $passwordfiletext.text | Sort-Object iloIP -Unique

                    $ProgressBar.Maximum=$csvfile.count
                    $ProgressBar.Value=0
                    $ProgressBar.Step=1
                    $OutputTextBox.Text="Please wait........."

                    $OutputTextBox.Text="Please wait, do not close or reset the tool...."

                    $csvresults=foreach($item in $csvfile) {
                        try {
                            $ErrorActionPreference="stop"
                            Import-Module hpeilocmdlets
                            $connection=Connect-HPEiLO $Item.iloIP -Username $Item.username -Password $Item.password `
                            -WarningAction Ignore
                            $AHS=Save-HPEiLOAHSLog -Connection $connection -Days 7 -FileLocation $filedirectory
                            Write-myLog -messages "Connection to $($item.iloIP) is secure"
                            if($ahs.status -eq "Error"){
                                throw
                            }
                            $Status="Success"
                            $Issue="No Error"
                        }
                        catch {
                            if($Error[0].Exception.Message -match  `
                                "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                -or $Error[0].Exception.Message -match  `
                                "The SSL connection could not be established, see inner exception"){
                                try {
                                    $ErrorActionPreference="stop"
                                    Import-Module hpeilocmdlets
                                    $connection=Connect-HPEiLO $Item.iloIP -Username $Item.username -Password $Item.password `
                                    -DisableCertificateAuthentication -WarningAction Ignore
                                    $AHS=Save-HPEiLOAHSLog -Connection $connection -Days 7 -FileLocation $filedirectory
                                    Write-myLog -messages "Connection to $($item.iloIP) is secure"
                                    if($ahs.status -eq "Error"){
                                        throw
                                    }
                                    $Status="Success"
                                    $Issue="No Error"
                                }
                                catch {
                                    if($AHS.status -eq "Error"){
                                        $status=$AHS.status
                                        $Issue=$AHS.statusinfo.message
                                    }
                                    else{
                                        $status="Failure"
                                        $Issue="$($Error[0].exception.message)"
                                    }
                                }
                            }
                            else{
                                if($AHS.status -eq "Error"){
                                    $status=$AHS.status
                                    $Issue=$AHS.statusinfo.message
                                }
                                else{
                                    $status="Failure"
                                    $Issue="$($Error[0].exception.message)"
                                }
                            }
                        }

                        [PSCustomObject]@{
                            'iLO IP'=$Item.iloIP
                            'AHS Download Status'=$Status
                            'Error'=$Issue
                        }
                    }

                    $outputtextbox.ForeColor="Green"
                    $OutputTextBox.Text="Please check the AHSINFO file to check the status of AHS logs..."
                    Write-myLog -level ERROR -messages "AHSINFO file generated"

                }
                else {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="CSV validation failed..."
                    Write-myLog -level ERROR -messages "CSV validation failed"
                    Write-myLog -level ERROR -messages $messages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $messages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
            catch {
                $ProgressBar.Value=0
                $outputtextbox.ForeColor="Red"
                $outputtextbox.text="You cannot define username or password with CSV file.."
                Write-myLog -level ERROR -messages "User defined username or password with CSV file"
                Start-Sleep -Seconds 1
            }
        }
        else{
            try {

                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $outputtextbox.ForeColor="Black"
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((![string]::IsNullOrEmpty($FilePathTextBox.text))){
                    $ipvalidationmessages=test-iloIP -path $FilePathTextBox.Text
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$fileiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined text file with successful validation"
                    Write-myLog -level INFO -messages "Text file path : $($FilePathTextBox.Text)"
                }
                elseif(![string]::IsNullOrEmpty($iLOTextbox.text)){
                    $ipvalidationmessages=test-iloIpstring -IPs $textiloips
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$textiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined manual iLO IPs with successful validation"
                }
                $ProgressBar.Maximum=$iloIPs.count
                $ProgressBar.Value=0
                $ProgressBar.Step=1
                $outputtextbox.ForeColor="Black"
                $OutputTextBox.Text="Please wait, do not close or reset the tool..."
                $csvresults=foreach($iloip in $iloIPs) {
                    try {
                        $ErrorActionPreference="stop"
                        Import-Module hpeilocmdlets
                        $connection=Connect-HPEiLO $iloIP -Username $user -Password $password `
                        -WarningAction Ignore
                        $AHS=Save-HPEiLOAHSLog -Connection $connection -Days 7 -FileLocation $filedirectory
                        Write-myLog -messages "Connection to $($iloip) is secure"
                        if($ahs.status -eq "Error"){
                            throw
                        }
                        $Status="Success"
                        $Issue="No Error"
                    }
                    catch {
                        if($Error[0].Exception.Message -match  `
                        "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                        -or $Error[0].Exception.Message -match  `
                        "The SSL connection could not be established, see inner exception"){
                            try {
                                $ErrorActionPreference="stop"
                                Import-Module hpeilocmdlets
                                $connection=Connect-HPEiLO $iloip -Username $user -Password $password `
                                -DisableCertificateAuthentication -WarningAction Ignore
                                $AHS=Save-HPEiLOAHSLog -Connection $connection -Days 7 -FileLocation $filedirectory
                                Write-myLog -messages "Connection to $($iloip) is unsecure"
                                if($ahs.status -eq "Error"){
                                    throw
                                }
                                $Status="Success"
                                $Issue="No Error"
                            }
                            catch {
                                if($AHS.status -eq "Error"){
                                    $status=$AHS.status
                                    $Issue=$AHS.statusinfo.message
                                }
                                else{
                                    $status="Failure"
                                    $Issue="$($Error[0].exception.message)"
                                }
                            }

                        }
                        else{
                            if($AHS.status -eq "Error"){
                                $status=$AHS.status
                                $Issue=$AHS.statusinfo.message
                            }
                            else{
                                $status="Failure"
                                $Issue="$($Error[0].exception.message)"
                            }
                        }
                    }
                    [PSCustomObject]@{
                        'iLO IP'=$iloip
                        'AHS Download Status'=$Status
                        'Error'=$Issue
                    }
                }

                $outputtextbox.ForeColor="Green"
                $OutputTextBox.Text="Please check the AHSINFO file to check the status of AHS logs..."
                Write-myLog -level INFO -messages "AHSINFO file generated"
            }
            catch {
                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User defined multiple fields"
                    $Error.Clear()
                }

                elseif((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User didn't define any of the field along with username and password"
                    $Error.Clear()
                }
                elseif((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($ilotextbox.text))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs to continue.."
                    Write-myLog -level ERROR -messages "User defined ilo and text field both"
                    $Error.Clear()
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.Text="If you define iLO IPs or Text File field, you must define username and Password."
                    Write-myLog -level ERROR -messages "User didn't define Username or password with ilo IPs or text file"
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))) {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define only one field from Text file, ILO IPs or CSV file."
                    Write-myLog -level ERROR -messages "User defined multiple fields among text,iLOIPs and csv"
                    $Error.Clear()
                }
                else{
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="IP validation failed..."
                    Write-myLog -level ERROR -messages "IP validation failed"
                    Write-myLog -level ERROR -messages $ipvalidationmessages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $ipvalidationmessages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
        }
        if($csvresults){
            $csvresults | Export-Csv -path $ahsPath -NoTypeInformation -Force
            Write-myLog -level INFO -messages $csvresults
            if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
            if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
            if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
            if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
            if(![string]::IsNullOrEmpty($csvfile)){Clear-Variable -Name csvfile}
            if(![string]::IsNullOrEmpty($user)){Clear-Variable -Name user}
            if(![string]::IsNullOrEmpty($Password)){Clear-Variable -Name Password}
        }
    }
    catch {
        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $outputtextbox.text="Please define any one field out of ILO IPs, Text File or CSV file to continue"
            Write-myLog -level ERROR -messages "User didn't define any of the field"
        }
        elseif((Test-FileLock -Path $AHSPath)){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="Please close the Ahsinfo file to create a new one."
            Write-myLog -level ERROR -messages "user had the AHSinfo file open while new one was being created"
        }
        else {
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="some error happened, $($Error[0].exception.message)"
            write-mylog -level ERROR -messages "some error happened, $($Error[0].exception.message)"
        }
    }
}

function PasswordFileLabelClick( $object ){

}

function ShowPasswordCheckedChanged( $object ){
	if ($ShowPassword.checked)
	{
		$PasswordTextbox.UseSystemPasswordChar=$false
	}
	else
	{
		$PasswordTextbox.UseSystemPasswordChar=$true
	}
}
function PasswordfileTextTextChanged( $object ){
    $script:csvfilepath=$PasswordfileText.text
}

function FilePathTextBoxTextChanged( $object ){
    if(!([string]::IsNullOrEmpty($FilePathTextBox.text))){
        $Script:fileiloIPs=Get-Content -Path $FilePathTextBox.text -ErrorAction SilentlyContinue
    }
}

function FileLabelClick( $object ){

}

function iLOTextChanged( $object ){
    $IP=$iLOTextbox.text
    $Script:textiloIPs=$IP.split(",")
}

function ILOLabelClick( $object ){

}

function OutputLabelClick( $object ){

}

function OutputTextChanged( $object ){

}

function PasswordLabelClick( $object ){

}

function UsernameLabelClick( $object ){

}

function PasswordTextChanged( $object ){
    $Script:Password=$PasswordTextbox.Text
}

function UsernameTextChanged( $object ){
    $Script:user=$UsernameTextbox.Text
}

# test csv - headers, Ilo Ips and missing entries
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

Function test-backupfile{
    param (
        [parameter(Mandatory=$false)]
        [string]$path

    )
    process{
        try {
            if(($path -notmatch "(\.bak)") -or !(Test-Path $path) -or !(Get-Content -Path $path)){
                throw
            }
        }
        catch {
            if($path -notmatch "(\.bak)"){
                Write-Output "Please enter path for a valid bak file."
            }
            elseif (!(Test-Path $path)) {
                Write-Output "Bak file doesn't exist at this location."
            }
            elseif(!(Get-Content -Path $path)){
                Write-Output "Bak file is blank, please enter a valid bak file."
            }
            else{
                Write-Output $Error[0].exception.message
            }
        }
    }
}
Function test-bin{
    param (
        [parameter(Mandatory=$false)]
        [string]$path

    )
    process{
        try {
            if(($path -notmatch "(\.bin)") -or !(Test-Path $path) -or !(Get-Content -Path $path)){
                throw
            }
        }
        catch {
            if($path -notmatch "(\.bin)"){
                Write-Output "Please enter path for a valid bin file."
            }
            elseif (!(Test-Path $path)) {
                Write-Output "Bin file doesn't exist at this location."
            }
            elseif(!(Get-Content -Path $path)){
                Write-Output "Bin file is blank, please enter a valid file."
            }
            else{
                Write-Output $Error[0].exception.message
            }
        }
    }
}

# test ILO IP - check if any IP given in text is valid or not
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

# testing if file is open and script throws
Function Test-FileLock {
    Param(
        [parameter(Mandatory=$True)]
        [string]$Path
    )
    $OFile = New-Object System.IO.FileInfo $Path
    If ((Test-Path -Path $Path -PathType Leaf) -eq $False) {Return $False}
    Else {
        Try {
            $OStream = $OFile.Open([System.IO.FileMode]::Open, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
            If ($OStream) {$OStream.Close()}
            Return $False
        }
        Catch {Return $True}
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
function LicenseButtonClick( $object ){
    Write-myLog -level INFO -messages "User clicked on License Button"
    $ErrorActionPreference="stop"
    $outputtextbox.ForeColor="Black"
    $outputtextbox.text="Validating information..."
    Start-Sleep -Seconds 1
    try {
        if((Test-FileLock -Path $licensePath)){
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $outputtextbox.text="Please wait..."
            Start-Sleep -Seconds 1
            throw
        }

        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and (![string]::IsNullOrEmpty($PasswordfileText.Text))){

            try {
                if((![string]::IsNullOrEmpty($UsernameTextbox.Text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.Text))){
                    $outputtextbox.text="Please wait..."
                    Start-Sleep -Seconds 1
                    throw
                }
                $messages=test-csv -path $PasswordfileText.Text
                if(!($messages)){
                    $outputtextbox.text="CSV is validated.."
                    Write-myLog -level INFO -messages "CSV validated"
                    Write-myLog -level INFO -messages "CSV file path : $($PasswordfileText.Text)"
                    Start-Sleep 2
                    $csvfile=import-csv -path $passwordfiletext.text | Sort-Object iloIP -Unique
                    $ProgressBar.Maximum=$csvfile.count
                    $ProgressBar.Value=0
                    $ProgressBar.Step=1
                    $OutputTextBox.Text="Please wait........."
                    $OutputTextBox.Text=("iLOIP"+","+"License Key"+","+"Type"+","+"Install Date"+","+"tier"+","+"Status"+","+"Error")
                    $csvresults=foreach($item in $csvfile){
                        try{
                            $connection=connect-hpeilo $item.iloIP -username $item.username -password $item.password `
                            -warningaction ignore
                            $licenseinfo=get-hpeilolicense -connection $connection
                            Write-myLog -messages "Connection to $($item.iloIP) is secure"
                            $IP=$item.iloIP
                            $Key=$licenseinfo.key
                            $Type=$licenseinfo.licensetype
                            $Install_date=$licenseinfo.licenseinstalldate
                            $Tier=$licenseinfo.licensetier
                            $Status="Success"
                            $Issue="No Error"
                            $OutputTextBox.AppendText("`n")
                            $OutputTextBox.AppendText($item.iloIP+","+$key+","+$type+","+`
                            $install_date+","+$tier+","+$status+","+$Issue)
                            $ProgressBar.PerformStep()
                        }
                        catch{
                            if($Error[0].Exception.Message -match  `
                                "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                                -or $Error[0].Exception.Message -match  "The SSL connection could not be established, see inner exception" ){
                                try {
                                    $connection=connect-hpeilo $item.iloIP -username $item.username -password $item.password `
                                    -disablecertificateauthentication -warningaction ignore
                                    $licenseinfo=get-hpeilolicense -connection $connection
                                    Write-myLog -messages "Connection to $($item.iloIP) is unsecure"
                                    $IP=$item.iloIP
                                    $Key=$licenseinfo.key
                                    $Type=$licenseinfo.licensetype
                                    $Install_date=$licenseinfo.licenseinstalldate
                                    $Tier=$licenseinfo.licensetier
                                    $Status="Success"
                                    $Issue="No Error"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($item.iloIP+","+$key+","+$type+","+`
                                    $install_date+","+$tier+","+$status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                                catch {
                                    $IP=$item.iloIP
                                    $Key="NA"
                                    $Type="NA"
                                    $Install_date="NA"
                                    $Tier="NA"
                                    $Status="Failure"
                                    $Issue="$($error[0].Exception.Message)"
                                    $OutputTextBox.AppendText("`n")
                                    $OutputTextBox.AppendText($item.iloIP+","+$key+","+$type+","+`
                                    $install_date+","+$tier+","+$status+","+$Issue)
                                    $ProgressBar.PerformStep()
                                }
                            }
                            else{
                                $IP=$item.iloIP
                                $Key="NA"
                                $Type="NA"
                                $Install_date="NA"
                                $Tier="NA"
                                $Status="Failure"
                                $Issue="$($error[0].Exception.Message)"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($item.iloIP+","+$key+","+$type+","+`
                                $install_date+","+$tier+","+$status+","+$Issue)
                                $ProgressBar.PerformStep()
                            }
                        }

                        [PSCustomObject]@{
                            'iLO IP'=$IP
                            'License Key'=$Key
                            'Type'=$Type
                            'Install date'=$Install_date
                            'Tier'=$Tier
                            'Status'=$Status
                            'Error'=$Issue
                        }
                    }
                }
                else {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="CSV validation failed..."
                    Write-myLog -level ERROR -messages "CSV validation failed"
                    Write-myLog -level ERROR -messages $messages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $messages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
            catch {
                $ProgressBar.Value=0
                $outputtextbox.ForeColor="Red"
                $outputtextbox.text="You cannot define username or password with CSV file"
                Write-myLog -level ERROR -messages "User defined username or password with CSV file"
                Start-Sleep -Seconds 1
            }
        }
        else{
            try {

                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }
                if((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $outputtextbox.ForeColor="Black"
                    $outputtextbox.text="Please wait......"
                    start-sleep -seconds 1
                    throw
                }

                if((![string]::IsNullOrEmpty($FilePathTextBox.text))){
                    $ipvalidationmessages=test-iloIP -path $FilePathTextBox.Text
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$fileiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined text file with successful validation"
                    Write-myLog -level INFO -messages "Text file path : $($FilePathTextBox.Text)"
                }
                elseif(![string]::IsNullOrEmpty($iLOTextbox.text)){
                    $ipvalidationmessages=test-iloIpstring -IPs $textiloips
                    if($ipvalidationmessages){
                        throw
                    }
                    $iloIPs=$textiloips | Sort-Object -Unique
                    Write-myLog -level INFO -messages "User defined manual iLO IPs with successful validation"
                }
                $ProgressBar.Maximum=$iloIPs.count
                $ProgressBar.Value=0
                $ProgressBar.Step=1
                $outputtextbox.ForeColor="Black"
                $OutputTextBox.Text="Please wait........."
                $OutputTextBox.Text=("iLOIP"+","+"License Key"+","+"Type"+","+"Install Date"+","+"tier"+","+"Status"+","+"Error")
                $csvresults=foreach($iloIP in $iloIPs){
                    try{
                        $connection=connect-hpeilo $iloIP -username $user -password $password -WarningAction Ignore
                        $licenseinfo=get-hpeilolicense -connection $connection
                        Write-myLog -messages "Connection to $($iloIP) is secure"
                        $IP=$iloIP
                        $Key=$licenseinfo.key
                        $Type=$licenseinfo.licensetype
                        $Install_date=$licenseinfo.licenseinstalldate
                        $Tier=$licenseinfo.licensetier
                        $Status="Success"
                        $Issue="No Error"
                        $OutputTextBox.AppendText("`n")
                        $OutputTextBox.AppendText($iloIP+","+$key+","+$type+","+`
                        $install_date+","+$tier+","+$status+","+$Issue)
                        $ProgressBar.PerformStep()
                    }
                    catch{
                        if($Error[0].Exception.Message -match  `
                        "The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel."`
                        -or $Error[0].Exception.Message -match "The SSL connection could not be established, see inner exception"){
                            try {
                                $connection=connect-hpeilo $iloIP -username $user -password $password -disablecertificateauthentication `
                                -warningaction ignore
                                $licenseinfo=get-hpeilolicense -connection $connection
                                Write-myLog -messages "Connection to $($iloIP) is unsecure"
                                $IP=$iloIP
                                $Key=$licenseinfo.key
                                $Type=$licenseinfo.licensetype
                                $Install_date=$licenseinfo.licenseinstalldate
                                $Tier=$licenseinfo.licensetier
                                $Status="Success"
                                $Issue="No Error"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($iloIP+","+$key+","+$type+","+`
                                $install_date+","+$tier+","+$status+","+$Issue)
                                $ProgressBar.PerformStep()
                            }
                            catch {
                                $IP=$iloIP
                                $Key="NA"
                                $Type="NA"
                                $Install_date="NA"
                                $Tier="NA"
                                $Status="Failure"
                                $Issue="$($error[0].Exception.Message)"
                                $OutputTextBox.AppendText("`n")
                                $OutputTextBox.AppendText($iloIP+","+$key+","+$type+","+`
                                $install_date+","+$tier+","+$status+","+$Issue)
                                $ProgressBar.PerformStep()
                            }
                        }
                        else{
                            $IP=$iloIP
                            $Key="NA"
                            $Type="NA"
                            $Install_date="NA"
                            $Tier="NA"
                            $Status="Failure"
                            $Issue="$($error[0].Exception.Message)"
                            $OutputTextBox.AppendText("`n")
                            $OutputTextBox.AppendText($iloIP+","+$key+","+$type+","+`
                            $install_date+","+$tier+","+$status+","+$Issue)
                            $ProgressBar.PerformStep()
                        }
                    }
                    [PSCustomObject]@{
                        'iLO IP'=$IP
                        'License Key'=$Key
                        'Type'=$Type
                        'Install date'=$Install_date
                        'Tier'=$Tier
                        'Status'=$Status
                        'Error'=$Issue
                    }
                }
            }
            catch {
                if(((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)) `
                -and (![string]::IsNullOrEmpty($PasswordTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text))) `
                -or ((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($PasswordfileText.text))) `
                -or ((![string]::IsNullOrEmpty($PasswordfileText.text)) -and (![string]::IsNullOrEmpty($iLOTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User defined multiple fields"
                    $Error.Clear()
                }

                elseif((([string]::IsNullOrEmpty($FilePathTextBox.text)) -and ([string]::IsNullOrEmpty($iLOTextbox.text))`
                -and ([string]::IsNullOrEmpty($PasswordfileText.text))) `
                -and (!([string]::IsNullOrEmpty($UsernameTextbox.text)) -or (![string]::IsNullOrEmpty($PasswordTextbox.text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs or CSV file to continue.."
                    Write-myLog -level ERROR -messages "User didn't define any of the field along with username and password"
                    $Error.Clear()
                }
                elseif((![string]::IsNullOrEmpty($FilePathTextBox.text)) -and (![string]::IsNullOrEmpty($ilotextbox.text))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define one field from Text file, ILO IPs to continue.."
                    Write-myLog -level ERROR -messages "User defined ilo and text field both"
                    $Error.Clear()
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))){
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.Text="If you define iLO IPs or Text File field, you must define username and Password."
                    Write-myLog -level ERROR -messages "User didn't define Username or password with ilo IPs or text file"
                }
                elseif(((![string]::IsNullOrEmpty($iLOTextbox.Text)) -or (![string]::IsNullOrEmpty($FilePathTextBox.Text))) `
                -and (([string]::IsNullOrEmpty($UsernameTextbox.Text)) -or ([string]::IsNullOrEmpty($PasswordTextbox.Text)))) {
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $OutputTextBox.text="Please define only one field from Text file, ILO IPs or CSV file."
                    Write-myLog -level ERROR -messages "User defined multiple fields among text,iLOIPs and csv"
                    $Error.Clear()
                }
                else{
                    $ProgressBar.Value=0
                    $outputtextbox.ForeColor="Red"
                    $outputtextbox.text="IP validation failed..."
                    Write-myLog -level ERROR -messages "IP validation failed"
                    Write-myLog -level ERROR -messages $ipvalidationmessages
                    $outputtextbox.AppendText("`n")
                    foreach($message in $ipvalidationmessages){
                        $outputtextbox.AppendText("`n")
                        $OutputTextBox.AppendText($message)
                    }
                }
            }
        }
        if($csvresults){
            $csvresults | Export-Csv -path $licensepath -NoTypeInformation -Force
            Write-myLog -level INFO -messages $csvresults
            if(![string]::IsNullOrEmpty($csvresults)){Clear-Variable -Name csvresults}
            if(![string]::IsNullOrEmpty($messages)){Clear-Variable -Name messages}
            if(![string]::IsNullOrEmpty($ipvalidationmessages)){Clear-Variable -Name ipvalidationmessages}
            if(![string]::IsNullOrEmpty($iloIPs)){Clear-Variable -Name iloips}
            if(![string]::IsNullOrEmpty($csvfile)){Clear-Variable -Name csvfile}
            if(![string]::IsNullOrEmpty($user)){Clear-Variable -Name user}
            if(![string]::IsNullOrEmpty($Password)){Clear-Variable -Name Password}
        }
    }
    catch {
        if(([string]::IsNullOrEmpty($iLOTextbox.Text)) -and ([string]::IsNullOrEmpty($FilePathTextBox.Text)) `
        -and ([string]::IsNullOrEmpty($PasswordfileText.Text)) -and ([string]::IsNullOrEmpty($UsernameTextbox.Text))`
        -and ([string]::IsNullOrEmpty($PasswordTextbox.Text))){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $outputtextbox.text="Please define any one field out of ILO IPs, Text File or CSV file to continue"
            Write-myLog -level ERROR -messages "User didn't define any of the field"
        }
        elseif((Test-FileLock -Path $licensePath)){
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="Please close the licenseinfo file to create a new one."
            Write-myLog -level ERROR -messages "user had the Licenseinfo file open while new one was being created"
        }
        else {
            $ProgressBar.Value=0
            $outputtextbox.ForeColor="Red"
            $OutputTextBox.text="some error happened, $($Error[0].exception.message)"
            Write-myLog -level ERROR -messages "some error happened, $($Error[0].exception.message)"
        }
    }
}
function Form1Load( $object ){

}

Main # This call must remain below all other event functions

#endregion
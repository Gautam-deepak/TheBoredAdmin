#Variables
$asbuilt_path="$env:USERPROFILE\Documents\Asbuilt"
If(!(Test-path -Path $asbuilt_path)){$null = New-Item -Name Asbuilt -Path $env:USERPROFILE\Documents -ItemType Directory}
$erroractionpreference="Stop"
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

#functions
function New-AsBuiltReportConfig {
    <#
    .SYNOPSIS
        Creates JSON configuration files for individual As Built Reports.
    .DESCRIPTION
        Creates JSON configuration files for individual As Built Reports.
    .PARAMETER Report
        Specifies the type of report configuration to create.
    .PARAMETER FolderPath
        Specifies the folder path to create the report JSON configuration file.
    .PARAMETER Filename
        Specifies the filename of the report JSON configuration file.
        If filename is not specified, a JSON configuration file will be created with a default filename AsBuiltReport.<Vendor>.<Product>.json
    .PARAMETER Force
        Specifies to overwrite any existing report JSON configuration file
    .EXAMPLE
        New-AsBuiltReportConfig -Report VMware.vSphere -FolderPath 'C:\Reports' -Filename 'vSphere_Report_Config'

        Creates a VMware vSphere report configuration file named 'vSphere_Report_Config.json' in the 'C:\Reports' folder.
    .EXAMPLE
        New-AsBuiltReportConfig -Report Nutanix.PrismElement -FolderPath '/Users/Tim/Reports' -Force

        Creates a Nutanix Prism Element report configuration file name 'AsBuiltReport.Nutanix.PrismElement.json' in '/Users/Tim/Reports' folder and overwrites the existing file.
    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Core
    .LINK
        https://www.asbuiltreport.com/user-guide/new-asbuiltreportconfig/
    #>
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Please provide the name of the report to generate the JSON configuration for'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( {
                $InstalledReportModules = Get-Module -Name "AsBuiltReport.*" -ListAvailable | Where-Object { $_.name -ne 'AsBuiltReport.Core' } | Sort-Object -Property Version -Descending | Select-Object -Unique
                $ValidReports = foreach ($InstalledReportModule in $InstalledReportModules) {
                    $NameArray = $InstalledReportModule.Name.Split('.')
                    "$($NameArray[-2]).$($NameArray[-1])"
                }
                if ($ValidReports -contains $_) {
                    $true
                } else {
                    throw "Invalid report type specified. Please use one of the following [$($ValidReports -Join ', ')]"
                }
            })]
        [String] $Report,

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Please provide the folder path to save the JSON configuration file'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Path')]
        [String] $FolderPath,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the filename of the JSON configuration file'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Name')]
        [String] $Filename,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Used to overwrite the destination file if it exists'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Overwrite')]
        [Switch] $Force
    )

    $DirectorySeparatorChar = [System.IO.Path]::DirectorySeparatorChar

    # Test to ensure the path the user has specified does exist
    if (-not (Test-Path -Path $($FolderPath))) {
        Write-Error "The folder '$($FolderPath)' does not exist. Please create the folder and run New-AsBuiltReportConfig again."
        break
    }
    # Find the root folder where the module is located for the report that has been specified
    try {
        $Module = Get-Module -Name "AsBuiltReport.$Report" -ListAvailable | Where-Object { $_.name -ne 'AsBuiltReport.Core' } | Sort-Object -Property Version -Descending | Select-Object -Unique
        $SourcePath = $($Module.ModuleBase) + $($DirectorySeparatorChar) + $($Module.Name) + ".json"
        if (Test-Path -Path $($SourcePath)) {
            Write-Verbose -Message "Processing $($Module.Name) report configuration file from module $($Module), version $($Module.Version)."
            if ($Filename) {
                $DestinationPath = $($FolderPath) + $($DirectorySeparatorChar) + $($Filename) + ".json"
                if (-not (Test-Path -Path $($DestinationPath))) {
                    Write-Verbose -Message "Copying report configuration file '$($SourcePath)' to '$($DestinationPath)'."
                    Copy-Item -Path $($SourcePath) -Destination "$($DestinationPath)"
                    Write-Output "$($Module.Name) report configuration file '$($Filename).json' created in '$($FolderPath)'."
                } elseif ($Force) {
                    Write-Verbose -Message "Copying report configuration file '$($SourcePath)' to '$($DestinationPath)'. Overwriting existing file."
                    Copy-Item -Path $($SourcePath) -Destination $($DestinationPath) -Force
                    Write-Output "$($Module.Name) report configuration file '$($Filename).json' created in '$($FolderPath)'."
                } else {
                    Write-Error "$($Module.Name) report configuration file '$($Filename).json' already exists in '$($FolderPath)'. Use 'Force' parameter to overwrite existing file."
                }
            } else {
                $DestinationPath = $($FolderPath) + $($DirectorySeparatorChar) + $($Module.Name) + ".json"
                if (-not (Test-Path -Path $($DestinationPath))) {
                    Write-Verbose -Message "Copying $($Module.Name) report configuration file '$($SourcePath)' to '$($DestinationPath)'."
                    Copy-Item -Path $($SourcePath) -Destination $($DestinationPath)
                    Write-Output "$($Module.Name) report configuration file '$($Module.Name).json' created in '$($FolderPath)'."
                } elseif ($Force) {
                    Write-Verbose -Message "Copying report configuration file '$($SourcePath)' to '$($DestinationPath)'. Overwriting existing file."
                    Copy-Item -Path $($SourcePath) -Destination $($DestinationPath) -Force
                    Write-Output "$($Module.Name) report configuration file '$($Module.Name).json' created in '$($FolderPath)'."
                } else {
                    Write-Error "$($Module.Name) report configuration file '$($Module.Name).json' already exists in '$($FolderPath)'. Use 'Force' parameter to overwrite existing file."
                }
            }
        } else {
            Write-Error "Report configuration file not found in module path '$($Module.ModuleBase)'."
        }
    } catch {
        Write-Error $_
    }
}

Register-ArgumentCompleter -CommandName 'New-AsBuiltReportConfig' -ParameterName 'Report' -ScriptBlock {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameter
    )

    $InstalledReportModules = Get-Module -Name "AsBuiltReport.*" -ListAvailable | Where-Object { $_.name -ne 'AsBuiltReport.Core' } | Sort-Object -Property Version -Descending | Select-Object -Unique
    $ValidReports = foreach ($InstalledReportModule in $InstalledReportModules) {
        $NameArray = $InstalledReportModule.Name.Split('.')
        "$($NameArray[-2]).$($NameArray[-1])"
    }

    $ValidReports | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}

function New-AsBuiltConfig {
    <#
    .SYNOPSIS
        Creates As Built Report configuration files.
    .DESCRIPTION
        New-AsBuiltConfig starts a menu-driven procedure in the powershell console and asks the user a series of questions
        Answers to these questions are optionally saved in a JSON configuration file which can then be referenced using the
        -AsBuiltConfigFilePath parameter using New-AsBuiltReport, to save having to answer these questions again and also to allow
        the automation of New-AsBuiltReport.

        New-AsBuiltConfig will automatically be called by New-AsBuiltReport if the -AsBuiltConfigFilePath parameter is not specified
        If a user wants to generate a new As Built Report configuration without running a new report, this cmdlet is exported
        in the AsBuiltReport powershell module and can be called as a standalone cmdlet.
    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Core
    .LINK
        https://www.asbuiltreport.com/user-guide/new-asbuiltconfig/
    #>

    [CmdletBinding()]
    param()

    #Run section to prompt user for information about the As Built Report to be exported to JSON format (if saved)
    $global:Config = @{ }
    $DirectorySeparatorChar = [System.IO.Path]::DirectorySeparatorChar

    #region Report configuration
    Clear-Host
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    Write-Host ' <        As Built Report Information      > ' -ForegroundColor Cyan
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    $ReportAuthor = Read-Host -Prompt "Enter the name of the Author for this As Built Report [$([System.Environment]::Username)]"
    if (($ReportAuthor -like $null) -or ($ReportAuthor -eq "")) {
        $ReportAuthor = $([System.Environment]::Username)
    }

    $Config.Report = @{
        'Author' = $ReportAuthor
    }
    #endregion Report configuration

    #region Company configuration
    Clear-Host
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    Write-Host ' <           Company Information           > ' -ForegroundColor Cyan
    Write-Host '---------------------------------------------' -ForegroundColor Cyan

    $CompanyInfo = Read-Host -Prompt "Would you like to enter Company information for the As Built Report? (y/n)"
    while ("y", "n" -notcontains $CompanyInfo) {
        $CompanyInfo = Read-Host -Prompt "Would you like to enter Company information for the As Built Report? (y/n)"
    }

    if ($CompanyInfo -eq 'y') {
        $CompanyFullName = Read-Host -Prompt "Enter the Full Company Name"
        $CompanyShortName = Read-Host -Prompt "Enter the Company Short Name"
        $CompanyContact = Read-Host -Prompt "Enter the Company Contact"
        $CompanyEmail = Read-Host -Prompt "Enter the Company Email Address"
        $CompanyPhone = Read-Host -Prompt "Enter the Company Phone"
        $CompanyAddress = Read-Host -Prompt "Enter the Company Address"
    }

    $Config.Company = @{
        'FullName' = $CompanyFullName
        'ShortName' = $CompanyShortName
        'Contact' = $CompanyContact
        'Email' = $CompanyEmail
        'Phone' = $CompanyPhone
        'Address' = $CompanyAddress
    }
    #endregion Company configuration

    #region Email configuration
    Clear-Host
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    Write-Host ' <            Email Configuration          > ' -ForegroundColor Cyan
    Write-Host '---------------------------------------------' -ForegroundColor Cyan
    if (-not ($SendEmail)) {
        $ConfigureMailSettings = Read-Host -Prompt "Would you like to enter SMTP configuration? (y/n)"
        while ("y", "n" -notcontains $ConfigureMailSettings) {
            $ConfigureMailSettings = Read-Host -Prompt "Would you like to enter SMTP configuration? (y/n)"
        }
    }
    if (($SendEmail) -or ($ConfigureMailSettings -eq "y")) {
        $MailServer = Read-Host -Prompt "Enter the mail server FQDN / IP address"
        while (($MailServer -eq $null) -or ($MailServer -eq "")) {
            $MailServer = Read-Host -Prompt "Enter the mail server FQDN / IP Address"
        }
        if (($MailServer -eq 'smtp.office365.com') -or ($MailServer -eq 'smtp.gmail.com')) {
            $MailServerPort = Read-Host -Prompt "Enter the mail server port number [587]"
            if (($MailServerPort -eq $null) -or ($MailServerPort -eq "")) {
                $MailServerPort = '587'
            }
        } else {
            $MailServerPort = Read-Host -Prompt "Enter the mail server port number [25]"
            if (($MailServerPort -eq $null) -or ($MailServerPort -eq "")) {
                $MailServerPort = '25'
            }
        }
        $MailServerUseSSL = Read-Host -Prompt "Use SSL for mail server connection? (true/false)"
        while ("true", "false" -notcontains $MailServerUseSSL) {
            $MailServerUseSSL = Read-Host -Prompt "Use SSL for mail server connection? (true/false)"
        }
        $MailServerUseSSL = Switch ($MailServerUseSSL) {
            "true" { $true }
            "false" { $false }
        }

        $MailCredentials = Read-Host -Prompt "Require mail server authentication? (true/false)"
        while ("true", "false" -notcontains $MailCredentials) {
            $MailCredentials = Read-Host -Prompt "Require mail server authentication? (true/false)"
        }
        $MailCredentials = Switch ($MailCredentials) {
            "true" { $true }
            "false" { $false }
        }

        $MailFrom = Read-Host -Prompt "Enter the mail sender address"
        while (($MailFrom -eq $null) -or ($MailFrom -eq "")) {
            $MailFrom = Read-Host -Prompt "Enter the mail sender address"
        }
        $MailRecipients = @()
        do {
            $MailTo = Read-Host -Prompt "Enter the mail server recipient address"
            $MailRecipients += $MailTo
            $AnotherRecipient = @()
            while ("y", "n" -notcontains $AnotherRecipient) {
                $AnotherRecipient = Read-Host -Prompt "Do you want to enter another recipient? (y/n)"
            }
        }until($AnotherRecipient -eq "n")
        $MailBody = Read-Host -Prompt "Enter the email message body content"
        if (($MailBody -eq $null) -or ($MailBody -eq "")) {
            $MailBody = "As Built Report attached"
        }
    }

    $Config.Email = @{
        'Server' = $MailServer
        'Port' = $MailServerPort
        'UseSSL' = $MailServerUseSSL
        'Credentials' = $MailCredentials
        'From' = $MailFrom
        'To' = $MailRecipients
        'Body' = $MailBody
    }
    #endregion Email Configuration

    #region Report Configuration Folder
    if ($Report -and (-not $ReportConfigFilePath)) {
        Clear-Host
        Write-Host '---------------------------------------------' -ForegroundColor Cyan
        Write-Host ' <          Report Configuration           > ' -ForegroundColor Cyan
        Write-Host '---------------------------------------------' -ForegroundColor Cyan
        $ReportConfigFolder = Read-Host -Prompt "Enter the full path of the folder to use for storing report configuration files and custom style scripts [$($Home + $DirectorySeparatorChar)AsBuiltReport]"
        if (($ReportConfigFolder -like $null) -or ($ReportConfigFolder -eq "")) {
            $ReportConfigFolder = $Home + $DirectorySeparatorChar + "AsBuiltReport"
        }

        #If the folder doesn't exist, create it
        if (-not (Test-Path -Path $ReportConfigFolder)) {
            Try {
                $Folder = New-Item -Path $ReportConfigFolder -ItemType Directory -Force
            } Catch {
                Write-Error $_
                break
            }
        }

        #Add the path to the folder to the report configuration file
        $Config.UserFolder = @{
            'Path' = $ReportConfigFolder
        }

        # Test to see if the report configuration file exists. If it doesn't exist, generate the report configuration file.
        # If the report configuration file exists, prompt the user to overwrite the report configuration file.
        $ReportModule = Get-Module -Name "AsBuiltReport.$Report" -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1
        $SourcePath = $($ReportModule.ModuleBase) + $DirectorySeparatorChar + $($ReportModule.Name) + ".json"
        $DestinationPath = $($ReportConfigFolder) + $DirectorySeparatorChar + $($ReportModule.Name) + ".json"
        if (-not (Get-ChildItem -Path $DestinationPath)) {
            Write-Verbose -Message "Copying '$($SourcePath)' to '$($DestinationPath)'."
            New-AsBuiltReportConfig -Report $Report -FolderPath $ReportConfigFolder
        } else {
            try {
                if (Test-Path -Path $DestinationPath) {
                    $OverwriteReportConfig = Read-Host -Prompt "A report configuration file already exists in the specified folder for $($ReportModule.Name). Would you like to overwrite it? (y/n)"
                    while ("y", "n" -notcontains $OverwriteReportConfig) {
                        $OverwriteReportConfig = Read-Host -Prompt "A report configuration file already exists in the specified folder for $($ReportModule.Name). Would you like to overwrite it? (y/n)"
                    }
                    if ($OverwriteReportConfig -eq 'y') {
                        Try {
                            Write-Verbose -Message "Copying '$($SourcePath)' to '$($DestinationPath)'. Overwriting existing file."
                            New-AsBuiltReportConfig -Report $Report -FolderPath $ReportConfigFolder -Force
                        } Catch {
                            Write-Error $_
                            Break
                        }
                    }
                }
            } catch {
                Write-Error $_
            }
        }
    }
    #endregion Report Configuration Folder
    <#
    #region Save configuration
    Clear-Host
    Write-Host '----------------------------------------------' -ForegroundColor Cyan
    Write-Host ' <       As Built Report Configuration      > ' -ForegroundColor Cyan
    Write-Host '----------------------------------------------' -ForegroundColor Cyan
    $SaveAsBuiltConfig = Read-Host -Prompt "Would you like to save the As Built Report configuration file? (y/n)"
    while ("y", "n" -notcontains $SaveAsBuiltConfig) {
        $SaveAsBuiltConfig = Read-Host -Prompt "Would you like to save the As Built Report configuration file? (y/n)"
    }

    if ($SaveAsBuiltConfig -eq 'y') {
        $AsBuiltName = Read-Host -Prompt "Enter a name for the As Built Report configuration file [AsBuiltReport]"
        if (($AsBuiltName -like $null) -or ($AsBuiltName -eq "")) {
            $AsBuiltName = "AsBuiltReport"
        }
        if ($Config.UserFolder.Path) {
            $AsBuiltExportPath = Read-Host -Prompt "Enter the path to save the As Built Report configuration file [$($Config.UserFolder.Path)]"
            if (($AsBuiltExportPath -like $null) -or ($AsBuiltExportPath -eq "")) {
                $AsBuiltExportPath = $Config.UserFolder.Path
            }
		} elseif ($ReportConfigFilePath) {
			$ReportConfigFolderPath = Split-Path -Path $ReportConfigFilePath
			$AsBuiltExportPath = Read-Host -Prompt "Enter the path to save the As Built Report configuration file [$ReportConfigFolderPath]"
			if (($AsBuiltExportPath -like $null) -or ($AsBuiltExportPath -eq "")) {
                $AsBuiltExportPath = $ReportConfigFolderPath
            }
        } else {
            $AsBuiltExportPath = Read-Host -Prompt "Enter the path to save the As Built Report configuration file [$($Home + $DirectorySeparatorChar)AsBuiltReport]"
            if (($AsBuiltExportPath -like $null) -or ($AsBuiltExportPath -eq "")) {
                $AsBuiltExportPath = $Home + $DirectorySeparatorChar + "AsBuiltReport"
            }
        }
		if (-not (Test-Path -Path $AsBuiltExportPath)) {
			Write-Verbose -Message "Creating As Built Report configuration folder '$AsBuiltExportPath'."
			Try {
				$Folder = New-Item -Path $AsBuiltExportPath -ItemType Directory -Force
			} Catch {
				Write-Error $_
				break
			}
		}
		$Config.UserFolder = @{
			'Path' = $AsBuiltExportPath
		}
        Write-Verbose -Message "Saving As Built Report configuration file '$($AsBuiltName).json' to path '$AsBuiltExportPath'."
        $AsBuiltConfigPath = Join-Path -Path $AsBuiltExportPath -ChildPath "$AsBuiltName.json"
        $Config | ConvertTo-Json | Out-File $AsBuiltConfigPath
    } else {
        Write-Verbose -Message "As Built Report configuration file not saved."
    }
    #endregion Save configuration
    #>
    # Print output to screen so that it can be captured to $Global:AsBuiltConfig variable in New-AsBuiltReport
    $Config

    # Verbose Output
    Write-Verbose -Message "Config.Report.Author = $ReportAuthor"
    Write-Verbose -Message "Config.UserFolder.Path = $ReportConfigFolder"
    foreach ($x in $Config.Company.Keys) {
        Write-Verbose -Message "Config.Company.$x = $($Config.Company[$x])"
    }
    foreach ($x in $Config.Email.Keys) {
        Write-Verbose -Message "Config.Email.$x = $($Config.Email[$x])"
    }
}#End New-AsBuiltConfig Function

function New-AsBuiltReport {
    <#
    .SYNOPSIS
        Documents the configuration of IT infrastructure in Word/HTML/Text formats using PScribo.
    .DESCRIPTION
        Documents the configuration of IT infrastructure in Word/HTML/Text formats using PScribo.
    .PARAMETER Report
        Specifies the type of report that will be generated.
    .PARAMETER Target
        Specifies the IP/FQDN of the system to connect.
        Multiple targets may be specified, separated by a comma.
    .PARAMETER Credential
        Specifies the stored credential of the target system.
    .PARAMETER Username
        Specifies the username for the target system.
    .PARAMETER Password
        Specifies the password for the target system.
    .PARAMETER Token
        Specifies an API token to authenticate to the target system.
    .PARAMETER MFA
        Use multifactor authentication to authenticate to the target system.
    .PARAMETER Format
        Specifies the output format of the report.
        The supported output formats are WORD, HTML & TEXT.
        Multiple output formats may be specified, separated by a comma.
    .PARAMETER Orientation
        Sets the page orientation of the report to Portrait or Landscape.
        By default, page orientation will be set to Portrait.
    .PARAMETER StyleFilePath
        Specifies the file path to a custom style .ps1 script for the report to use.
    .PARAMETER OutputFolderPath
        Specifies the folder path to save the report.
    .PARAMETER Filename
        Specifies a filename for the report.
    .PARAMETER Timestamp
        Specifies whether to append a timestamp string to the report filename.
        By default, the timestamp string is not added to the report filename.
    .PARAMETER EnableHealthCheck
        Performs a health check of the target environment and highlights known issues within the report.
        Not all reports may provide this functionality.
    .PARAMETER SendEmail
        Sends report to specified recipients as email attachments.
    .PARAMETER AsBuiltConfigFilePath
        Enter the full file path to the As Built Report configuration JSON file.
        If this parameter is not specified, the user will be prompted for this configuration information on first
        run, with the option to save the configuration to a file.
    .PARAMETER ReportConfigFilePath
        Enter the full file path to a report JSON configuration file
        If this parameter is not specified, a default report configuration JSON is copied to the specifed user folder.
        If this parameter is specified and the path to a JSON file is invalid, the script will terminate.
    .EXAMPLE
        New-AsBuiltReport -Report VMware.vSphere -Target 192.168.1.100 -Username admin -Password admin -Format HTML,Word -EnableHealthCheck -OutputFolderPath 'c:\scripts\'

        Creates a VMware vSphere As Built Report in HTML & Word formats. The document will highlight particular issues which exist within the environment.
        The report will be saved to c:\scripts.
    .EXAMPLE
        $Creds = Get-Credential
        New-AsBuiltReport -Report PureStorage.FlashArray -Target 192.168.1.100 -Credential $Creds -Format Text -Timestamp -OutputFolderPath 'c:\scripts\'

        Creates a Pure Storage FlashArray As Built Report in Text format and appends a timestamp to the filename.
        Stored credentials are used to connect to the system.
        The report will be saved to c:\scripts.
    .EXAMPLE
        New-AsBuiltReport -Report Rubrik.CDM -Target 192.168.1.100 -Token '123456789abcdefg' -Format HTML -OutputFolderPath 'c:\scripts\'

        Creates a Rubrik CDM As Built Report in HTML format.
        An API token is used to connect to the system.
        The report will be saved to c:\scripts.
    .EXAMPLE
        New-AsBuiltReport -Report Cisco.UCSManager -Target '192.168.1.100' -Username admin -Password admin -StyleFilePath '/Users/Tim/AsBuiltReport/Styles/ACME.ps1' -OutputFolderPath '/Users/Tim/scripts'

        Creates a Cisco UCS Manager As Built Report in default format (Word), using a custom style.
        The report will be saved to '/Users/Tim/scripts'.
    .EXAMPLE
        New-AsBuiltReport -Report Nutanix.PrismElement -Target 192.168.1.100 -Username admin -Password admin -SendEmail -OutputFolderPath c:\scripts\

        Creates a Nutanix Prism Element As Built Report in default format (Word). Report will be attached and sent via email.
        The report will be saved to c:\scripts.
    .EXAMPLE
        New-AsBuiltReport -Report VMware.vSphere -Target 192.168.1.100 -Username admin -Password admin -Format HTML-AsBuiltConfigFilePath C:\scripts\asbuiltreport.json -OutputFolderPath c:\scripts\

        Creates a VMware vSphere As Built Report in HTML format, using the configuration in the asbuiltreport.json file located in the C:\scripts\ folder.
        The report will be saved to c:\scripts.
    .LINK
        https://github.com/AsBuiltReport/AsBuiltReport.Core
    .LINK
        https://www.asbuiltreport.com/user-guide/new-asbuiltreport/
    #>

    #region Script Parameters
    [CmdletBinding(
        PositionalBinding = $false,
        DefaultParameterSetName = 'Credential'
    )]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'Please specify which report type you wish to run.'
        )]
        [ValidateScript( {
                $InstalledReportModules = Get-Module -Name "AsBuiltReport.*" -ListAvailable | Where-Object { $_.name -ne 'AsBuiltReport.Core' } | Sort-Object -Property Version -Descending | Select-Object -Unique
                $ValidReports = foreach ($InstalledReportModule in $InstalledReportModules) {
                    $NameArray = $InstalledReportModule.Name.Split('.')
                    "$($NameArray[-2]).$($NameArray[-1])"
                }
                if ($ValidReports -contains $_) {
                    $true
                } else {
                    throw "Invalid report type specified. Please use one of the following [$($ValidReports -Join ', ')]"
                }
            })]
        [String] $Report,

        [Parameter(
            Position = 1,
            Mandatory = $true,
            HelpMessage = 'Please provide the IP/FQDN of the system'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Cluster', 'Server', 'IP')]
        [String[]] $Target,
        [Parameter(
            Position = 2,
            Mandatory = $true,
            HelpMessage = 'Please provide credentials to connect to the system',
            ParameterSetName = 'Credential'
        )]
        [ValidateNotNullOrEmpty()]
        [PSCredential] $Credential,

        [Parameter(
            Position = 2,
            Mandatory = $true,
            HelpMessage = 'Please provide the username to connect to the target system',
            ParameterSetName = 'UsernameAndPassword'
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Username,

        [Parameter(
            Position = 3,
            Mandatory = $true,
            HelpMessage = 'Please provide the password to connect to the target system',
            ParameterSetName = 'UsernameAndPassword'
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Password,

        [Parameter(
            Position = 3,
            Mandatory = $true,
            HelpMessage = 'Please provide an API token to connect to the target system',
            ParameterSetName = 'APIToken'
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Token,

        [Parameter(
            Position = 3,
            Mandatory = $true,
            ParameterSetName = 'MFA'
        )]
        [ValidateNotNullOrEmpty()]
        [Switch] $MFA,

        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'Please provide the document output format'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Word', 'HTML', 'Text')]
        [Array] $Format = 'Word',

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Determines the document page orientation'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateSet('Portrait', 'Landscape')]
        [String] $Orientation = 'Portrait',

        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Please provide the path to the document output file'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('OutputPath')]
        [String] $OutputFolderPath,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Please provide the path to the custom style script'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('StylePath')]
        [String] $StyleFilePath,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Provide the file path to an existing report JSON Configuration file'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('ReportConfigPath')]
        [String] $ReportConfigFilePath,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Provide the file path to an existing As Built JSON Configuration file'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('AsBuiltConfigPath')]
        [String] $AsBuiltConfigFilePath,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specify the As Built Report filename'
        )]
        [ValidateNotNullOrEmpty()]
        [String] $Filename,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specify whether to append a timestamp to the document filename'
        )]
        [Switch] $Timestamp = $false,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specify whether to highlight any configuration issues within the document'
        )]
        [Switch] $EnableHealthCheck = $false,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specify whether to send report via Email'
        )]
        [Switch] $SendEmail = $false
    )
    #endregion Script Parameters

    $DirectorySeparatorChar = [System.IO.Path]::DirectorySeparatorChar

    try {

        # If Username and Password parameters used, convert specified Password to secure string and store in $Credential
        if (($Username -and $Password)) {
            $SecurePassword = ConvertTo-SecureString $Password -AsPlainText -Force
            $Credential = New-Object System.Management.Automation.PSCredential ($Username, $SecurePassword)
        }

        if (-not (Test-Path $OutputFolderPath)) {
            Write-Error "OutputFolderPath '$OutputFolderPath' is not a valid folder path."
            break
        }
        #region Variable config

        # Import the AsBuiltReport JSON configuration file
        # If no path was specified, or the specified file doesn't exist, call New-AsBuiltConfig to walk the user through the menu prompt to create a config JSON
        if ($AsBuiltConfigFilePath) {
            if (Test-Path -Path $AsBuiltConfigFilePath) {
                $Global:AsBuiltConfig = Get-Content -Path $AsBuiltConfigFilePath | ConvertFrom-Json
                # Verbose Output for As Built Report configuration
                Write-Verbose -Message "Loading As Built Report configuration from '$AsBuiltConfigFilePath'."
            } else {
                Write-Error "Could not find As Built Report configuration in path '$AsBuiltConfigFilePath'."
                break
            }
        } else {
            Write-Verbose -Message "Generating new As Built Report configuration"
            $Global:AsBuiltConfig = New-AsBuiltConfig
        }

        # Set ReportConfigFilePath as Global scope for use in New-AsBuiltConfig
        if ($ReportConfigFilePath) {
            $Global:ReportConfigFilePath = $ReportConfigFilePath
        }

        # If StyleFilePath was specified, ensure the file provided in the path exists, otherwise exit with error
        if ($StyleFilePath) {
            if (-not (Test-Path -Path $StyleFilePath)) {
                Write-Error "Could not find report style script in path '$StyleFilePath'."
                break
            }
        }

        # Report Module Information
        $Global:Report = $Report
        $ReportModuleName = "AsBuiltReport.$Report"
        $ReportModulePath = (Get-Module -Name $ReportModuleName -ListAvailable | Sort-Object -Property Version -Descending | Select-Object -First 1).ModuleBase

        if ($ReportConfigFilePath) {
            # If ReportConfigFilePath was specified, ensure the file provided in the path exists, otherwise exit with error
            if (-not (Test-Path -Path $ReportConfigFilePath)) {
                Write-Error "Could not find $ReportModuleName report configuration file in path '$ReportConfigFilePath'."
                break
            } else {
                #Import the Report Configuration in to a variable
                Write-Verbose -Message "Loading $ReportModuleName report configuration file from path '$ReportConfigFilePath'."
                $Global:ReportConfig = Get-Content -Path $ReportConfigFilePath | ConvertFrom-Json
            }
        } else {
            # If a report config hasn't been provided, check for the existance of the default JSON in the paths the user specified in base config
            $ReportConfigFilePath =  $ReportModulePath + $DirectorySeparatorChar + "$($ReportModuleName).json"

            if (Test-Path -Path $ReportConfigFilePath) {
                Write-Verbose -Message "Loading report configuration file from path '$ReportConfigFilePath'."
                $Global:ReportConfig = Get-Content -Path $ReportConfigFilePath | ConvertFrom-Json
            } else {
                Write-Error "Report configuration file not found in module path '$ReportModulePath'."
                break
            }#End if test-path
        }#End if ReportConfigFilePath

        # If Filename parameter is not specified, set filename to the report name
        if (-not $Filename) {
            $FileName = $ReportConfig.Report.Name
        }
        # If Timestamp parameter is specified, add the timestamp to the report filename
        if ($Timestamp) {
            $FileName = $Filename + " - " + (Get-Date -Format 'yyyy-MM-dd_HH.mm.ss')
        }
        Write-Verbose -Message "Setting report filename to '$FileName'."

        # If the EnableHealthCheck parameter has been specified, set the global healthcheck variable so report scripts can reference the health checks
        if ($EnableHealthCheck) {
            $Global:Healthcheck = $ReportConfig.HealthCheck
        }

        # Set Global scope for Orientation parameter
        $Global:Orientation = $Orientation

        #endregion Variable config

        #region Email Server Authentication
        # If Email Server Authentication is required, prompt user for credentials
        if ($SendEmail -and $AsBuiltConfig.Email.Credentials) {
            Clear-Host
            Write-Host '---------------------------------------------' -ForegroundColor Cyan
            Write-Host '  <        Email Server Credentials       >  ' -ForegroundColor Cyan
            Write-Host '---------------------------------------------' -ForegroundColor Cyan
            $MailCredentials = Get-Credential -Message "Please enter the credentials for $($AsBuiltConfig.Email.Server)"
            Clear-Host
        }
        #endregion Email Server Authentication

        #region Generate PScribo document
        # if Verbose has been passed
        if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {
            $AsBuiltReport = Document $FileName -Verbose {
                # Set Document Style
                if ($StyleFilePath) {
                    Write-PScriboMessage "Executing report style script from path '$StyleFilePath'."
                    . $StyleFilePath
                } else {
                    $StyleFilePath = $ReportModulePath + $DirectorySeparatorChar + $($ReportModuleName) + ".Style.ps1"
                    Write-PScriboMessage "Executing report style script from path '$($StyleFilePath)'."
                    . $StyleFilePath
                }
                # StylePath parameter is legacy, to allow older reports to be generated without issues. It will be removed at a later date.
                # If Credential has been passed or previously created via Username/Password
                if ($Credential) {
                    & "Invoke-$($ReportModuleName)" -Target $Target -Credential $Credential -Verbose -StylePath $true
                }
                elseif ($Token) {
                    & "Invoke-$($ReportModuleName)" -Target $Target -Token $Token -Verbose -StylePath $true
                }
                elseif ($MFA) {
                    & "Invoke-$($ReportModuleName)" -Target $Target -MFA -Verbose -StylePath $true
                }
            }
        } else {
            $AsBuiltReport = Document $FileName {

                Write-Host "Please wait while the $($Report.Replace("."," ")) As Built Report is being generated." -ForegroundColor Green

                # Set Document Style
                if ($StyleFilePath) {
                    Write-PScriboMessage "Executing report style script from path '$StyleFilePath'."
                    . $StyleFilePath
                } else {
                    $StyleFilePath = $ReportModulePath + $DirectorySeparatorChar + $($ReportModuleName) + ".Style.ps1"
                    Write-PScriboMessage "Executing report style script from path '$($StyleFilePath)'."
                    . $StyleFilePath
                }
                # StylePath parameter is legacy, to allow older reports to be generated without issues. It will be removed at a later date.
                # If Credential has been passed or previously created via Username/Password
                if ($Credential) {
                    & "Invoke-$($ReportModuleName)" -Target $Target -Credential $Credential -StylePath $true
                }
                elseif ($Token) {
                    & "Invoke-$($ReportModuleName)" -Target $Target -Token $Token -StylePath $true
                }
                elseif ($MFA) {
                    & "Invoke-$($ReportModuleName)" -Target $Target -MFA -StylePath $true
                }
            }
        }
        Try {
            $Document = $AsBuiltReport | Export-Document -Path $OutputFolderPath -Format $Format -Options @{ TextWidth = 240 } -PassThru
            Write-Output "$($Report.Replace("."," ")) As Built Report '$FileName' has been saved to '$OutputFolderPath'."
        } catch {
            $Err = $_
            Write-Error $Err
        }
        #endregion Generate PScribo document

        #region Send-Email
        if ($SendEmail) {
            $EmailArguments = @{
                Attachments = $Document
                To = $AsBuiltConfig.Email.To
                From = $AsBuiltConfig.Email.From
                Subject = $ReportConfig.Report.Name
                Body = $AsBuiltConfig.Email.Body
                SmtpServer = $AsBuiltConfig.Email.Server
                Port = $AsBuiltConfig.Email.Port
                UseSSL = $AsBuiltConfig.Email.UseSSL
            }

            if ($AsBuiltConfig.Email.Credentials) {
                # Send the report via SMTP using SSL
                Send-MailMessage @EmailArguments -Credential $MailCredentials
            } else {
                # Send the report via SMTP
                Send-MailMessage @EmailArguments
            }
        }
        #endregion Send-Email

        #region Globals cleanup
        Remove-Variable -Name AsBuiltConfig -Scope Global
        Remove-Variable -Name ReportConfig -Scope Global
        Remove-Variable -Name Report -Scope Global
        Remove-Variable -Name Orientation -Scope Global
        if ($ReportConfigFilePath) {
            Remove-Variable -Name ReportConfigFilePath
        }
        if ($Healthcheck) {
            Remove-Variable -Name Healthcheck -Scope Global
        }
        #endregion Globals cleanup

    } catch {
        Write-Error $_
    }
}

Register-ArgumentCompleter -CommandName 'New-AsBuiltReport' -ParameterName 'Report' -ScriptBlock {
    param (
        $commandName,
        $parameterName,
        $wordToComplete,
        $commandAst,
        $fakeBoundParameter
    )

    $InstalledReportModules = Get-Module -Name "AsBuiltReport.*" -ListAvailable | Where-Object { $_.name -ne 'AsBuiltReport.Core' } | Sort-Object -Property Version -Descending | Select-Object -Unique
    $ValidReports = foreach ($InstalledReportModule in $InstalledReportModules) {
        $NameArray = $InstalledReportModule.Name.Split('.')
        "$($NameArray[-2]).$($NameArray[-1])"
    }

    $ValidReports | Where-Object { $_ -like "$wordToComplete*" } | ForEach-Object {
        [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
    }
}


#Main
Write-Banner -FontSize 10 "Asbuilt Report"
Write-Host '---------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host '                   Welcome to AsBuilt Report Automation                    ' -ForegroundColor Cyan
Write-Host '---------------------------------------------------------------------------' -ForegroundColor Cyan
Write-Host `n
Import-Module PSMenu
Write-Output "Please select one of the option to continue"
$main_selected_option=Show-Menu @("VmWare","Veeam","Microsoft","Nutanix","Rubrik",$(Get-MenuSeparator),"Quit")
switch ($main_selected_option) {
    VmWare { 
        write-host `n
        Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
        $internal_selected_option=Show-Menu @("ESXi","VSphere","Horizon","SRM","AppVolumes","CloudFoundation","UAG","vROps",`
        "NSXv","NSX-T","vRA",$(Get-MenuSeparator),"Quit")
        if($internal_selected_option -eq "Quit"){
            Write-Error "User cancelled the process"
        }
        else{
            try {
                #Import-Module $("Asbuildreport"+"."+$main_selected_option+"."+$internal_selected_option)
                New-AsBuiltReportConfig -Report $($main_selected_option+"."+$internal_selected_option) `
                -FolderPath $asbuilt_path -Filename "$($main_selected_option+"_"+$internal_selected_option)_config" -Force
                $target=Read-host "Enter target of $($internal_selected_option)"
                $username=Read-host "Enter username to connect to $($target)"
                $password=Read-host "Enter password of $($username)"
                New-AsBuiltReport -Report $($main_selected_option+"."+$internal_selected_option) -Target $target -Username $username `
                -Password $password -Format Text,Html,Word -OutputFolderPath $asbuilt_path `
                -ReportConfigFilePath "$asbuilt_path\$($main_selected_option+"_"+$internal_selected_option)_config.json" -Verbose
            }
            catch {
                Write-Error "$($Error[0].Exception.Message)"
            }
        }
    }
    Microsoft{
        write-host `n
        $internal_selected_option=Show-Menu @("Azure","AD","Windows","Intune","SCVMM",$(Get-MenuSeparator),"Quit")
        if($internal_selected_option -eq "Quit"){
            Write-Error "User cancelled the process"
        }
        else{
            try {
                try{
                    Write-Verbose -Message "Installing needed modules....."
                    if($internal_selected_option -eq "Windows"){
                        # DNS/DHCP Server powershell modules
                        Install-WindowsFeature -Name RSAT-DNS-Server
                        Install-WindowsFeature -Name RSAT-DHCP

                        # Hyper-V Server powershell modules
                        Install-WindowsFeature -Name Hyper-V-PowerShell

                        #IIS Server powershell modules
                        Install-WindowsFeature -Name web-mgmt-console
                        Install-WindowsFeature -Name Web-Scripting-Tools
                    }
                    if($internal_selected_option -eq "AD"){
                        # ADCS PowerShell Module
                        Install-WindowsFeature -Name RSAT-ADCS,RSAT-ADCS-mgmt
                        
                        # DNS/DHCP Server powershell modules
                        Install-WindowsFeature -Name RSAT-DNS-Server
                        Install-WindowsFeature -Name RSAT-DHCP

                        # AD PowerShell Modules
                        Install-WindowsFeature -Name RSAT-AD-PowerShell
                        Install-WindowsFeature -Name GPMC
                    }
                }
                catch{
                    Write-Error "$($Error[0].Exception.Message)"
                    break
                }
                #Import-Module $("Asbuildreport"+"."+$main_selected_option+"."+$internal_selected_option)
                New-AsBuiltReportConfig -Report $($main_selected_option+"."+$internal_selected_option) `
                -FolderPath $asbuilt_path -Filename "$($main_selected_option+"_"+$internal_selected_option)_config" -Force
                $target=Read-host "Enter target of $($internal_selected_option)"
                $username=Read-host "Enter username to connect to $($target)"
                $password=Read-host "Enter password of $($username)"
                New-AsBuiltReport -Report $($main_selected_option+"."+$internal_selected_option) -Target $target -Username $username `
                -Password $password -Format Text,Html,Word -OutputFolderPath $asbuilt_path `
                -ReportConfigFilePath "$asbuilt_path\$($main_selected_option+"_"+$internal_selected_option)_config.json" -Verbose
            }
            catch {
                Write-Error "$($Error[0].Exception.Message)"
            }
        }
    }
    Nutanix{
        write-host `n
        $internal_selected_option=Show-Menu @("PrismElement","PrismCentral",$(Get-MenuSeparator),"Quit")
        if($internal_selected_option -eq "Quit"){
            Write-Error "User cancelled the process"
        }
        else{
            try {
                #Import-Module $("Asbuildreport"+"."+$main_selected_option+"."+$internal_selected_option)
                New-AsBuiltReportConfig -Report $($main_selected_option+"."+$internal_selected_option) `
                -FolderPath $asbuilt_path -Filename "$($main_selected_option+"_"+$internal_selected_option)_config" -Force
                $target=Read-host "Enter target of $($internal_selected_option)"
                $username=Read-host "Enter username to connect to $($target)"
                $password=Read-host "Enter password of $($username)"
                New-AsBuiltReport -Report $($main_selected_option+"."+$internal_selected_option) -Target $target -Username $username `
                -Password $password -Format Text,Html,Word -OutputFolderPath $asbuilt_path `
                -ReportConfigFilePath "$asbuilt_path\$($main_selected_option+"_"+$internal_selected_option)_config.json" -Verbose
            }
            catch {
                Write-Error "$($Error[0].Exception.Message)"
            }
        }
    }
    Veeam{
        Set-ExecutionPolicy RemoteSigned
        write-host `n
        $internal_selected_option=Show-Menu @("VBR",$(Get-MenuSeparator),"Quit")
        if($internal_selected_option -eq "Quit"){
            Write-Error "User cancelled the process"
        }
        else{
            try {
                #Import-Module $("Asbuildreport"+"."+$main_selected_option+"."+$internal_selected_option)
                New-AsBuiltReportConfig -Report $($main_selected_option+"."+$internal_selected_option) `
                -FolderPath $asbuilt_path -Filename "$($main_selected_option+"_"+$internal_selected_option)_config" -Force
                $target=Read-host "Enter target of $($internal_selected_option)"
                $username=Read-host "Enter username to connect to $($target)"
                $password=Read-host "Enter password of $($username)"
                New-AsBuiltReport -Report $($main_selected_option+"."+$internal_selected_option) -Target $target -Username $username `
                -Password $password -Format Text,Html,Word -OutputFolderPath $asbuilt_path `
                -ReportConfigFilePath "$asbuilt_path\$($main_selected_option+"_"+$internal_selected_option)_config.json" -Verbose
            }
            catch {
                Write-Error "$($Error[0].Exception.Message)"
            }
        }
    }
    Rubrik{
        $internal_selected_option=Show-Menu @("CDM",$(Get-MenuSeparator),"Quit")
        if($internal_selected_option -eq "Quit"){
            Write-Error "User cancelled the process"
        }
        else{
            try {
                #Import-Module $("Asbuildreport"+"."+$main_selected_option+"."+$internal_selected_option)
                New-AsBuiltReportConfig -Report $($main_selected_option+"."+$internal_selected_option) `
                -FolderPath $asbuilt_path -Filename "$($main_selected_option+"_"+$internal_selected_option)_config" -Force
                $target=Read-host "Enter target of $($internal_selected_option)"
                $username=Read-host "Enter username to connect to $($target)"
                $password=Read-host "Enter password of $($username)"
                New-AsBuiltReport -Report $($main_selected_option+"."+$internal_selected_option) -Target $target -Username $username `
                -Password $password -Format Text,Html,Word -OutputFolderPath $asbuilt_path `
                -ReportConfigFilePath "$asbuilt_path\$($main_selected_option+"_"+$internal_selected_option)_config.json" -Verbose
            }
            catch {
                Write-Error "$($Error[0].Exception.Message)"
            }
        }
    }
    Quit {
        Write-Error "User has quit the operation"
    }
}

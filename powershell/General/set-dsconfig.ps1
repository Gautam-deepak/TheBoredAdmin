Configuration DeployHostFile # PART1
	{  
	 
    Import-Module -ModuleName 'PSDesiredStateConfiguration'

	  param( # PART2
	    [Parameter(Mandatory=$true)] 
	    [String[]]$Servers, 
	    [Parameter(Mandatory=$true)] 
	    [String]$SourceFile, 
	    [Parameter(Mandatory=$true)] 
	    [String]$DestinationFile,
        [Parameter(Mandatory=$true)]
        [String]$Role
	  ) 
	
	  Node $Servers # PART3
	  {  
	    File ResName # PART4
	    { 
	        Ensure = "Present" 
	        Type = "File" 
	        SourcePath = $SourceFile
	        DestinationPath = $DestinationFile
	    } 
	  }  
	
	  Node $Servers # PART3 bis
	  {  
	    WindowsFeature ActiveDirectory # PART4 bis
	    { 
	        Ensure = "Present" #Part 5
            Name = $role
	    } 
	  }  
	
	} 
    
    # Save the configuration run it as Function:
    # Here I want to deploy this file: "\\Share\Hosts" on two machines "ADM01","ADM11" in the following `
    # folder "C:\Windows\System32\drivers\etc\". This will create two .mof(managed Object format) file one for each server
    # in outputpath, which will be deployed using start-dsconfiguration


    <#
    MOF Files are generally used to manage systems that use Windows Management Instrumentation (WMI) or Common Information Model (CIM). 
    MOF files are a good way to manipulate WMI settings because MOF files contains WMI classes. 
    MOF files are then compiled using “mofcomp.exe” into the WMI repository.
    #>
    # Part 6
    DeployHostFile
  	-Servers @("ADM01","ADM11")
  	-SourceFile  "\\Share\Hosts"
  	-DestinationFile  "C:\Windows\System32\drivers\etc\"
  	-OutputPath  "C:\DeployHostFile\"
    -Role "ADDS"

    <#
    ‘Local Configuration Manager’ or LCM is the execution engine of DSC. It works on each node and it is this that will apply the configurations. `
    When sending a configuration to a node, LCM will analyse the .mof file. After reading the file, it calls all DSC resources that are present `
    on the node so as to configure the machine as requested. Finally, its role is to control configuration-drift on the machine.
    #>
    #Part 7
    Start-DscConfiguration -wait -Verbose -Path C:\DeployHostfile\


    Configuration LCMConfiguration
    {
        Node $env:COMPUTERNAME
        {
            LocalConfigurationManager
            {
                RebootNodeIfNeeded = $True
            }
        }
    }
    
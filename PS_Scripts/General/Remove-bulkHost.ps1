
param (
    [Parameter(Mandatory=$True)]
    
    [string] $hostfilepath
)

# Checking for temp directory
$temp="C:\temp"

if(!(test-path $temp)){
    write-verbose -Message "Creating temp directory" -Verbose
    New-Item -Name temp -Path c:\ -ItemType directory -ErrorAction silentlycontinue | out-null
    write-verbose -Message "temp directory created" -Verbose
} else {
    write-verbose -message " temp directory already exist" -Verbose
}

$computers=Get-Content $hostfilepath # host file path

$ErrorActionPreference="stop"

$results=foreach ($computer in $computers) { 
try{
    # remove AD computer
    Get-ADComputer -identity $computer.Trim() -ErrorAction SilentlyContinue | Remove-ADObject -Recursive -Confirm:$false
    $status="Object Deleted" # setting status to deleted
} 
catch{
    $status="Object doesn't exist" # setting status to not found , if get any error
    }


[pscustomobject]@{
'Computer'=$computer
'Status'=$status 
    }
}

$results # Publishing results in command line 
$results | Export-Csv -NoTypeInformation -Force -Path c:\Temp\results.csv # publishing results in temp directory
write-verbose -Message "Please check results.csv at c:\temp for more information" -Verbose
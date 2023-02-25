
param (
    [Parameter(Mandatory=$True)]
    
    [string] $hostfilepath
)

#variables

$temp="C:\temp"
$ErrorActionPreference="stop"

# Checking for temp directory

if(!(test-path $temp)){
    write-verbose -Message "Creating temp directory" -Verbose
    New-Item -Name temp -Path c:\ -ItemType directory -ErrorAction silentlycontinue | out-null
    write-verbose -Message "temp directory created" -Verbose
} else {
    write-verbose -message " temp directory already exist" -Verbose
}

#Importing CSV file

$csv=Import-Csv -path $hostfilepath # host file path

# Setting progess with int 

[int]$i="0"

# Taking output in report file

$results=foreach ($item in $csv) { 
    try {

        #Accessing the user using UGDN 

        $user=get-aduser -identity $item.id

        # Checking for user using email address

        #$user=get-aduser -filter  "EmailAddress -eq '$($item.ID)'"
        
        # Checking for group
    
        $group=get-adgroup -Identity $item.group

        # checking if user is in group

        if(Get-ADGroupMember -Identity $group | Where-Object {$_.name -eq $user.name}){
            remove-ADgroupMember -identity $group -members $user -confirm:$false
            $column3="User removed from Group"
        }
        else{
            $column3="User not in the Group"    
        }
        
        
        
    }
    catch  {
        try{
        $group=get-adgroup -Identity $item.group
        $column3="user Doesn't exist"
        }
        catch{
        if($item.group.length -gt "64"){
        $column3="Group Length exceeds beyond 64 characters"
        }
        else{
        $column3="Group doesn't exist"
        }
        }
    }

[pscustomobject]@{
'ID'=$item.id
'Group'=$item.Group
'Status'=$column3 
}
$i++
Write-Progress -Activity "Performing Operation" -Status  ('At row {0} out of {1}' -f $i,$csv.length) -PercentComplete ($i/$csv.Length*100)
}

$results # Publishing results in command line 
$results | Export-Csv -NoTypeInformation -Force -Path c:\Temp\results.csv # publishing results in temp directory
write-verbose -Message "Please check results.csv at c:\temp for more information" -Verbose



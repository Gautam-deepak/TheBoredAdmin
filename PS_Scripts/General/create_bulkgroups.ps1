#Import CSV
$groups = Import-Csv 'C:\Users\groups.csv' 

# Loop through the CSV
[int]$i="0"
$result=foreach ($group in $groups) {
        try {
        
        New-ADGroup -Name $group.group -Path $group.path -GroupCategory $group.type -GroupScope $group.scope
        $issue="no error"    
        $status="Group Created"

    }
    catch {
        $status =" Group not created"
        $issue=$Error[0].Exception.Message
    }

[pscustomobject]@{
'Group'=$group.group
'Status'=$status
'Error'=$issue

    }
$i++
Write-Progress -Activity "Performing Operation" -Status  ('At row {0} out of {1}' -f $i,$groups.length) -PercentComplete ($i/$groups.Length*100)
}
$result | Export-Csv -NoTypeInformation -Force -Path c:\Temp\results.csv # publishing results in temp directory

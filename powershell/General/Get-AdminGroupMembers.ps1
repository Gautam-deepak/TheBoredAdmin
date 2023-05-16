# Script is to full members of all Admin groups in active Directory and export them to CSV file

$groups=@("Domain Admins","Administrators","Schema Admins","Enterprise admins","DNSAdmins","Enterprise Key Admins","Key admins","Storage Replica Administrators")

foreach($group in $groups){

    Get-ADgroupmember -Identity $group | Select-Object @{Label="Group";Expression={$group}},distinguishedname,Name,ObjectClass,objectGuid,SamAccountname,SID | `
    Export-Csv -path "C:\temp\AdminGroupMembers.csv" -Force -NoTypeInformation -Append
}
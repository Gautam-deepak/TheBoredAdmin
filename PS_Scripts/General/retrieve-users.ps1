$ou=""
$exportPath="c:\temp\usersreport.csv"
Get-ADUser -Filter 'enabled -eq "true"' -SearchBase $ou -Properties name,physicalDeliveryOfficeName,userPrincipalname | `
Select-Object name,physicalDeliveryOfficeName,userPrincipalname | `
export-csv -NoTypeInformation -Force -Path $exportPath
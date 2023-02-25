Function Compare-ObjectProperties {
Param(
[PSObject]$ReferenceObject,
[PSObject]$DifferenceObject
)
$objprops = $ReferenceObject | Get-Member -MemberType Property,NoteProperty | % Name
$objprops += $DifferenceObject | Get-Member -MemberType Property,NoteProperty | % Name
$objprops = $objprops | Sort-Object | Select-Object -Unique
$diffs = @()
foreach ($objprop in $objprops) {
$diff = Compare-Object $ReferenceObject $DifferenceObject -Property $objprop
if ($diff) {
$diffprops = @{
PropertyName=$objprop
RefValue=($diff | Where-Object {$_.SideIndicator -eq '<='} | ForEach-Object $($objprop))
DiffValue=($diff | Where-Object {$_.SideIndicator -eq '=>'} | ForEach-Object $($objprop))
}
$diffs += New-Object PSObject -Property $diffprops
}
}
if ($diffs) {return ($diffs | Select-Object PropertyName,RefValue,DiffValue)}
}

$ad1 = Get-ADUser amelia.mitchell -Properties *
$ad2 = Get-ADUser carolyn.quinn -Properties *
Compare-ObjectProperties $ad1 $ad2

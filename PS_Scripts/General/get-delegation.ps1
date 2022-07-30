$OUs=Get-ADOrganizationalUnit -Filter * | Select-Object Distinguishedname -ExpandProperty distinguishedname
$users=@("testing","testing2")
$results=@()
$finalresults=@()

$results=foreach ($OU in $OUs){
    
(Get-Acl "AD:$ou").access | Select-Object @{Name='OU'; Expression={$ou}},Activedirectoryrights,InheritanceType,AccessControlType,IdentityReference
    
}

$finalresults=
    foreach($result in $results){

        Foreach($user in $users){

            $result | where-object{ $_.identityreference -like "novaprime\$user"}
    }
}

$finalresults | export-csv -Path C:\results.csv -NoTypeInformation -Force
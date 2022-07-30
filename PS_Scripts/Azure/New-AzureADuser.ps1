# Must be tried on PS 5.1 , doesn't work on PS 7

#connect-azuread -Credential $credential (works with NON-MFA Accounts)

connect-azuread #(interative login)

#variables
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$domain="novaprime.in"
$n="1"

#functions

function get-password {
    param (
       [string]$length
    )
    $Password = New-Object -TypeName PSObject
    $Password | Add-Member -MemberType ScriptProperty -Name "Password" -Value { ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | `
    Sort-Object {Get-Random})[0..$length] -join '' }
    $Pass=$Password.Password
    return $Pass
}


$PasswordProfile.Password = get-password -length 20
$user= Read-host "Enter New User Name"

New-AzureADUser -DisplayName $user -PasswordProfile $PasswordProfile -UserPrincipalName $upn -AccountEnabled $true -MailNickName ($user.Split()[0])

$n=0
$upn="tattiprasad@novaprime.in"
if(!(Get-AzureADUser -SearchString $upn -ErrorAction SilentlyContinue)){
    $upn=($user -replace '\s','') + "@" + $domain
    return $upn
}else{
    do {
        $n++
        $upn=($user -replace '\s','') + $n + "@" + $domain
        return $upn
        
    } until (!(Get-AzureADUser -SearchString $upn -ErrorAction SilentlyContinue) )
}

$a=0
do {
    
    
    $a++
    $a
} until ($a -eq 5)
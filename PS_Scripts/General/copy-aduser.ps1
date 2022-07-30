# Import active directory module for running AD cmdlets
Import-Module activedirectory
  
#Store the data from ADUsers.csv in the $ADUsers variable
$ADUsers = Import-csv .\bulk_users.csv

# Function to create random password 

function get-password {
    param (
       [string]$length
    )
    $Password = New-Object -TypeName PSObject
    $Password | Add-Member -MemberType ScriptProperty -Name "Password" `
    -Value { ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | `
    Sort-Object {Get-Random})[0..$length] -join '' }
    $Pass=$Password.Password
    $Pass
}


$results=foreach ($User in $ADUsers)
{
    Try {
           
        #Set password for new user 
        $temppass=(get-password -length 20)
        $password = ConvertTo-SecureString -String $temppass -AsPlainText -Force
        #Copy user - user01
        $userInstance = Get-ADUser -Identity $user.ugdn 

        #Create a new user from user01
        New-ADUser -name $user.name -SAMAccountName $User.new_ugdn -userprincipalname `
        ($user.new_ugdn+"@domain.com")  -Instance $userInstance `
        -AccountPassword $password -Path $user.OU -Description "PAM Accounts" -ChangePasswordAtLogon $true -Enabled $true 
        
        $userprincipal=$user.new_ugdn+"@domain.com"
        $status = "User Created"
        $issue="No Error"
        $passwordtemp=$temppass

    } Catch {
        if($($Error[0].exception.message) -eq "The specified account already exists"){
            $userprincipal=$user.new_ugdn+"@domain.com"
            $status = "User Created"
            $issue="No Error"
            $passwordtemp=$temppass
        }
        else{
            $userprincipal="NA"
            $status = "User Creation Failed"
            $issue=$($Error[0].exception.message)
            $passwordtemp="NA"

        }
        
    }

    Finally{
        $Error.Clear()
    }

[pscustomobject]@{
    'Name'=$user.name
    'UGDN'=$user.ugdn
    'New UGDN'=$user.new_ugdn
    'OU'=$user.OU
    'User Principal Name'=$userprincipal
    'Password'=$passwordtemp
    'Status'=$status
    'Error'=$issue
    }
}

$results | Export-Csv c:\temp\results.csv -NoTypeInformation -Force
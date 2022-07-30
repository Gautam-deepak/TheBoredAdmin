# copy ad user memberships to another

$users=import-csv -Path "C:\Users\users.csv"




$results=foreach ($User in $Users)
{
    Try {
        
        $CopyFromUser = Get-ADUser -Identity $user.ugdn -Property MemberOf
        $CopyToUser = Get-ADUser -Identity $user.new_ugdn -Property MemberOf
        $CopyFromUser.MemberOf | Where-Object{$CopyToUser.MemberOf -notcontains $_} |  Add-ADGroupMember -Member $CopyToUser  
        
        $status="Copied"
        $issue="none"
        

    } Catch {
        $status="Not Copied"
        $issue=($($Error[0]).Exception.Message)
    }

    Finally{
        $Error.Clear()
    }

[pscustomobject]@{
    'UGDN'=$user.ugdn
    'New UGDN'=$user.new_ugdn
    'Memberships'=$status
    'Error'=$issue
    }
}

$results | Export-Csv c:\temp\results.csv -NoTypeInformation -Force
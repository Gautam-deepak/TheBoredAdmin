param(
    [string]$filepath
)


$users = Import-Csv -Path C:\Temp\email_update.csv

$ErrorActionPreference="Stop"

$results = foreach ($user in $users)
{
    Write-Host "Working on $($user.sAMAccountname)" -ForegroundColor "green"

    If (get-aduser -Identity $user.samaccountname)
    {
        Try {
           
            Set-ADUser -Identity $user.samaccountname -EmailAddress $user.mail
                                    
            $status = "Success"
            $issue="No Error"

        } Catch {
            
            $status = "Failed"
            $issue=$($Error[0].exception.message)

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        
        $status = "Not Updated"
        $issue="$($user) not Found"
    }
    
    [pscustomobject]@{
        'user'=$user.sAMAccountname
        'mail'=$user.mail
        'Status'=$status
        'Error'=$issue
        
    }
}

$results | Export-Csv -NoTypeInformation -Path C:\results.csv -Force
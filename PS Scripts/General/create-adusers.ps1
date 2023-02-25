
<# 

User Creation pre-req

1. First Name (m)
2. Last Name (o)
3. Full Name (auto fill)
4. User Logon Name (define criteria and mandatory)
5. Password (auto fill and sent to HPE email address)
6. HPE Email address (M)
7. Options 
    a. User must change password at next logon
    b. User cannot change password
    c. Password never expires

#>



function create-aduser {
    [CmdletBinding()]
    param (
        [Parameter(mandatory=$true)]
        [string]$firstname,
        [Parameter(mandatory=$false)]
        [string]$Lastname,
        [Parameter(mandatory=$true)]
        [string]$Email,
        [Parameter(mandatory=$true)]
        [string]$UserlogonName,
        [Parameter(mandatory=$true)]
        [string]$options="User must change password at next logon"
    
    )
    
    begin {
        
    }
    
    process {
        
    }
    
    end {
        
    }
}


# Main

Write-host "

     #####################################################################################
     #                                                                                   #
     #              Welcome to the command line utility to create AD Users               #
     #                                                                                   #
     #####################################################################################
                                                                                            "

     Start-Sleep -Seconds 1

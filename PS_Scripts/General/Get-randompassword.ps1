    function get-password {
        param (
           [string]$length
        )
        $Password = New-Object -TypeName PSObject
    $Password | Add-Member -MemberType ScriptProperty -Name "Password" -Value { ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | `
    Sort-Object {Get-Random})[0..$length] -join '' }
    $Password.Password
    }

    $mystream = [IO.MemoryStream]::new([byte[]][char[]]$password)
    Get-FileHash -InputStream $mystream -Algorithm SHA256
     

    do {
        $Password = New-Object -TypeName PSObject
        $Password | Add-Member -MemberType ScriptProperty -Name "Password" -Value { ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | `
        Sort-Object {Get-Random})[0..30] -join '' }
        $Pass=$Password.Password
        $mystream = [IO.MemoryStream]::new([byte[]][char[]]$pass)
        $hash=Get-FileHash -InputStream $mystream -Algorithm SHA256
    } until ($hash.hash.StartsWith("00"))


    function get-password {
        param (
           [string]$length="20"
        )
        $Password = New-Object -TypeName PSObject
        $Password | Add-Member -MemberType ScriptProperty -Name "Password" -Value { ("!@#$%^&*0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz".tochararray() | `
        Sort-Object {Get-Random})[0..$length] -join '' }
        $Pass=$Password.Password
        $Pass
    }

    #random password using .net 

    # Import the system.web assembly

    Add-Type -AssemblyName 'System.Web'

    $randomPassword=[system.web.security.membership]::generatepassword(20,5)
    
    function get-password {
        
        param (
           [string]$length="20"
        )
        
        Add-Type -AssemblyName 'System.Web'

        $randomPassword=[system.web.security.membership]::generatepassword($length,5)

        $randomPassword
    }
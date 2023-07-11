# Define your PowerShell script code here
    function Get-Greeting {
        param (
            [string]$Name
        )
        if ($Name) {
            "Hello, $Name! Welcome to PowerShell."
        } else {
            "Hello, stranger! Welcome to PowerShell."
        }
    }

    

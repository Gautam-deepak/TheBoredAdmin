function get-logonhistory{
    Param (
    [string]$Computer,
    [int]$Days = 10
    )
    
    $Result = @()
    Write-Host "Gathering Event Logs, this can take awhile..."
    $ELogs = Get-EventLog System -Source Microsoft-Windows-WinLogon -After (Get-Date).AddDays(-$Days) `
    -ComputerName $Computer
    If ($ELogs){ 
        Write-Host "Processing..."
        ForEach ($Log in $ELogs){ 
            If ($Log.InstanceId -eq 7001){ 
                $ET = "Logon"
            }
            ElseIf ($Log.InstanceId -eq 7002){ 
                $ET = "Logoff"
            }
            Else{ 
                Continue
            }
            $Result += New-Object PSObject -Property @{
                'Server'=$Computer
                'User' = (New-Object System.Security.Principal.SecurityIdentifier `
                $Log.ReplacementStrings[1]).Translate([System.Security.Principal.NTAccount])
                'Time' = $Log.TimeWritten
                'Event Type' = $ET
            }
        }
        $Result | Select-Object Server,User,Time,"Event Type" | Sort-Object Time -Descending | `
        Export-Csv -NoTypeInformation -Force C:\Temp\$env:COMPUTERNAME.csv
        Write-Host "Done."
    }
    Else{ 
        Write-Host "Problem with $Computer."
        Write-Host "If you see a 'Network Path not found' error, try starting the Remote `
        Registry service on that computer."
        Write-Host "Or there are no logon/logoff events (XP requires auditing be turned on)"
    }
}

# MAIN
get-logonhistory -Computer $env:COMPUTERNAME -Days 90
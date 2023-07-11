. .\testparameters.ps1

describe 'Set-Computer' {
    It 'when a server name is passed, it returns the right string' {
        Set-Computer -ComputerName 'MYSRV' | should -Be 'Did that thing to the server'
    }
    It 'when anything other than server name is passed, it returns the right string' {
        Set-Computer -ComputerName 'MYCLIENT' | should -Be 'Did that thing to the client'
    }
}

<#
• What if someone tries to use a space in ComputerName?
• What if someone tries to use a special character in ComputerName?
• What if SRV is in the middle of ComputerName somewhere?
#>

Describe 'Set-Computer'{
    BeforeAll{
       $testcases = @( @{ ComputerName = 'FOOSRV' } )   
    }
    
    It 'when a server name is passed, it returns the right string' -TestCases $testCases {
        param($ComputerName) 
    Set-Computer -ComputerName $ComputerName | should -Be 'Did that thing to the server'
    }
}

Describe 'Set-Computer'{
    $testCases = @(
        @{ ComputerName = 'FOOSRV' }
        @{ ComputerName = 'FOO SRV' }
        @{ ComputerName = 'FOOSRV' }
        @{ ComputerName = 'FOOSRVSRV' }
    )
    
    It 'when a server name is passed, it returns the right string' -TestCases $testCases {
        param($ComputerName) 
    Set-Computer -ComputerName $ComputerName | should -Be 'Did that thing to the server'
    }
}

Describe 'Set-Computer'{
    $testCases = @(
        @{ ComputerName = 'FOOSRV'; TestName = 'SRV at the end' }
        @{ ComputerName = 'FOO SRV'; TestName = 'space in computer name' }
        @{ ComputerName = 'FOOSRV'; TestName = 'asterisk in computer name' }
        @{ ComputerName = 'FOOSRVSRV'; TestName = 'two iterations of "SRV" in computer name' }
    )
    
    It 'when a server name is passed, it returns the right string: <TestName>' -TestCases $testCases {
        param($ComputerName)
    Set-Computer -ComputerName $ComputerName | should -Be 'Did that thing to the server'
    }
}
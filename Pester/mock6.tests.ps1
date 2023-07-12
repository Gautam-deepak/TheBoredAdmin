. .\mock5.ps1

. .\mock5.ps1

describe 'Get-Employee' {
    mock 'Import-Csv' {
        [pscustomobject]@{
            FirstName = 'Adam'
            LastName = 'Bertram'
            UserName = 'abertram'
        }
    }
    it 'returns all expected users' {
        $users = Get-Employee
        $users.FirstName | should -Be 'Adam'
        $users.Lastname | should -Be 'Bertram'
        $users.UserName | should -Be 'abertram'
    }

    It 'runs the Import-Csv command assert' {
        Assert-MockCalled -CommandName 'Import-Csv'
    }

    It 'runs the Import-Csv command assert times' {
        Assert-MockCalled -CommandName 'Import-Csv' -Times 1
    }

    It 'runs the Import-Csv command assert times exactly' {
        Assert-MockCalled -CommandName 'Import-Csv' -Times 1 -Exactly
    }
}
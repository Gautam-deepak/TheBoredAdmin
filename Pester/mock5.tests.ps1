. .\mock5.ps1

describe 'Get-Employee' {
    mock -CommandName 'Import-Csv' -MockWith {
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
    Assert-MockCalled -CommandName Import-Csv -Times 1 
    }
}
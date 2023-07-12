describe 'My tests' {
    it 'displays the number 1' {
        1 | should -Be 1
    }
    it -Skip 'Checks the database' {    
        Test-DBConnect | should -BeOfType System.Data.SqlClient.SqlConnection
    }        
    it -Pending "Isn't done yet" { }
}
    
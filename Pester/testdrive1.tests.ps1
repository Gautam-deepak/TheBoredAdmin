. .\testdrive1.ps1

Describe "Set file" {
    BeforeAll { 
        $testPath = "TestDrive:"
        Set-File -filename test -path $testPath
    }

    It "Get-content of test file" {
        Get-Content $testPath\test.txt | Should -Be "Hello"
    }
    It "No file name passed" {
        Set-File | Should -Be "no file name defined"
    }
}
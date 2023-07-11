. .\mock4.ps1

Describe "Testing Test-LocalFile Command" {
    BeforeAll{
        $testpath="Testdrive:\a.txt"
        New-Item -Path $testpath -ItemType File 
    }
    Context "When the file exists" {
        It "Should return true" {
            $result = Test-LocalFile -FilePath $testpath
            $result | Should -Be $true
        }
    }


    Context "When an error occurs" {

        It "Should throw an error" {
            { Test-LocalFile -FilePath 'C:\path\to\file.txt' } | Should -Throw 
        }

        It "Should write the error message" {
            { Test-LocalFile -FilePath 'C:\path\to\file.txt' -erroraction stop} | Should -Throw "Cannot find path 'C:\path\to\file.txt' because it does not exist."
        }
    }
}

. .\testregistry.ps1

describe 'Get-RegPath' {
    BeforeAll { 
        $testPath = "TestRegistry:"
        New-Item -Path $testPath -Name TestLocation
        New-ItemProperty -Path $testpath\TestLocation -Name 'InstallPath' -Value 'C:\Program Files\MyApplication'
    }

    It 'reads the install path from the registry' {
        Get-RegPath -Path $testPath\TestLocation -Key 'InstallPath' | Should -Be 'C:\Program Files\MyApplication'
    }
}
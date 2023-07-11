Describe "Testing Get-Volume Command" {
    Context "When Get-Volume returns a valid volume object" {
        BeforeEach {
            Mock Get-Volume { return [pscustomobject]@{ DriveLetter = 'C:'; FileSystemLabel = 'OS'; Size = 100GB } }
        }

        It "Should return the expected drive letter" {
            $volume = Get-Volume -DriveLetter 'C:'
            $volume.DriveLetter | Should -Be 'C:'
        }

        It "Should return the expected file system label" {
            $volume = Get-Volume -DriveLetter 'C:'
            $volume.FileSystemLabel | Should -Be 'OS'
        }

        It "Should return the expected size" {
            $volume = Get-Volume -DriveLetter 'C:'
            $actualSize = $($volume.Size / 1GB)
            $actualSize | Should -Be '100'
        }

        It "Should have a size greater than 0" {
            $volume = Get-Volume -DriveLetter 'C:'
            $volume.Size | Should -BeGreaterThan 0
        }
    }

    Context "When Get-Volume returns no volumes" {
        BeforeEach {
            Mock Get-Volume { return @() }
        }

        It "Should return an empty result" {
            $volume = Get-Volume -DriveLetter 'C:'
            $volume | Should -BeNullOrEmpty
        }
    }
}

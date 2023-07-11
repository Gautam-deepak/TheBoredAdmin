Describe "Testing Set-Volume Command" {
    Context "When Set-Volume is successful" {
        BeforeEach {
            Mock Set-Volume { return $true }
            Mock Get-Volume { return [pscustomobject]@{ DriveLetter = 'C:'; FileSystemLabel = 'newlabel'; Size = 100GB } }
        }

        It "Should return success" {
            $result = Set-Volume -DriveLetter 'C' -NewFileSystemLabel 'NewLabel'
            $result | Should -Be $true
        }

        It "Should set the correct file system label" {
            $fileSystemLabel = "NewLabel"
            Set-Volume -DriveLetter 'C' -NewFileSystemLabel $fileSystemLabel | Out-Null
            $volume = Get-Volume -DriveLetter 'Newlabel'
            $volume.FileSystemLabel | Should -Be $fileSystemLabel
        }
    }

    Context "When Set-Volume fails" {
        BeforeEach {
            Mock Set-Volume { throw "Failed to set volume" }
            
        }

        It "Should throw an exception" {
            { Set-Volume -DriveLetter 'C' -NewFileSystemLabel 'NewLabel'  } | Should -Throw
        }
    }

    Context "When drive letter is not found" {
        BeforeEach {
            Mock Get-Volume { return @() }
            Mock Set-Volume {retrun throw}
        }

        It "Should throw an exception" {
            { Set-Volume -DriveLetter 'C' -NewFileSystemLabel 'NewLabel' } | Should -Throw
        }
    }
}

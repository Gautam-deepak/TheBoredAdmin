describe 'testing' {
    it 'testing' {
        mock 'Get-Item' {
            New-MockObject -Type 'System.IO.FileInfo'
        }
        Get-Item -Path 'doesnotexist' | should -BeOfType 'System.IO.FileInfo'
    }
}
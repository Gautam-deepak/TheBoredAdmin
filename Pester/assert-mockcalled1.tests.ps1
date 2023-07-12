. .\assert-mockcalled1.ps1

describe 'Do-Something' {
    mock 'Get-Content'
    it 'get-content should be called twice' {
        Do-Something -Path 'C:\ShouldCall.txt'
        Assert-MockCalled -CommandName 'Get-Content' -Times 2
    }
    it 'should not try to read the C:\ShouldNotCall.txt file' {
        Do-Something -Path 'C:\ShouldCall.txt'
        Assert-MockCalled -CommandName 'Get-Content' -ExclusiveFilter { $Path -eq 'C:\ShouldCall.txt' }
    }
}
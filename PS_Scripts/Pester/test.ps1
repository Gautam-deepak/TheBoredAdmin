Describe "Test Cases Pester" {
    Context "Test Cases for Directory" {
        It "ROFL Existence" {
            $result=Get-Item -Path C:\rofl -ErrorAction SilentlyContinue
            $final=($null -eq $result)
            $final | should -Be $false
        }
    }
}
. .\mock8.ps1
Describe "get-password" {
    Mock 'Get-Password' { 'GregShieldsIsMyHero.HesSoDreamy' }

    It "Should call Get-Password with the correct parameters" {
        # Call the function that invokes Get-Password
        $credential = Get-Credential -UserName 'abertram'
        $result = Get-Password -Credential $credential

        $assmParams = @{
            CommandName = 'Get-Password'
            ParameterFilter = { $Credential.UserName -eq 'abertram' }
        }

        Assert-MockCalled @assmParams
        $result | Should -Be 'GregShieldsIsMyHero.HesSoDreamy'
    }
}

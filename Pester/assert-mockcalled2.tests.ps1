. .\assert-mockcalled2.ps1

Describe "Get-Total" {
    It "Calculates the sum of two numbers" {

        # Mock the 'Measure-Object' cmdlet
        Mock -CommandName Measure-Object {}

        # Call the Get-Total function
        Get-Total -Number1 $Number1 -Number2 $Number2

        # Assert that the 'Measure-Object' cmdlet was called with the correct parameters
        Assert-MockCalled -CommandName Measure-Object -Times 1
    }
}

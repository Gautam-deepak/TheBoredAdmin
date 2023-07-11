. .\sample1.ps1
# Begin the Pester test block
Describe "Get-Greeting Tests" {
    
    It "Should greet the user with their name" {
        # Arrange
        $name = "John"
        $expectedOutput = "Hello, John! Welcome to PowerShell."

        # Act
        $output = Get-Greeting -Name $name

        # Assert
        $output | Should -Be $expectedOutput
    }

    It "Should greet a stranger when no name is provided" {
        # Arrange
        $expectedOutput = "Hello, stranger! Welcome to PowerShell."

        # Act
        $output = Get-Greeting

        # Assert
        $output | Should -Be $expectedOutput
    }
}


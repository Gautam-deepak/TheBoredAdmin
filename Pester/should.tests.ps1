# should be

describe 'Stupid-simple, unnecessary math test' {
    it '1+1 should -Be 2' {
    1 + 1 | should -Be 2
    }
}

# String Comparison Tests

Describe "String Comparison Tests" {
    It "Should compare two strings for equality (case-sensitive)" {
        # Arrange & Act
        $actual = "word"
        $expected = "Word"

        # Assert
        $actual | Should -Be $expected
    }

    It "Should compare two strings for inequality (case-sensitive)" {
        # Arrange & Act
        $actual = "word"
        $expected = "phrase"

        # Assert
        $actual | Should -Not -Be $expected
    }
}

# Should benullorempty

Describe "Variable Tests" {
    Context "When the variable is assigned a value" {
        It "Should not be null or empty" {
            # Arrange
            $variable = 'somevalue'

            # Assert
            $variable | Should -Not -BeNullOrEmpty
        }
    }
}

# String Comparison Tests

Describe "String Comparison Tests" {
    It "Should compare two strings for exact equality (case-sensitive)" {
        # Arrange & Act
        $actual = "word"
        $expected = "WORD"

        # Assert
        $actual | Should -BeExactly $expected
    }
}

# Numeric Comparison Tests

Describe "Numeric Comparison Tests" {
    It "Should check if a number is not greater than another number" {
        # Arrange & Act
        $actual = 1
        $expected = 0

        # Assert
        $actual | Should -Not -BeGreaterThan $expected
    }

    It "Should check if a number is less than another number" {
        # Arrange & Act
        $actual = 1
        $expected = 0

        # Assert
        $actual | Should -BeLessThan $expected
    }
}

# Numeric Comparison Tests

Describe "Numeric Comparison Tests" {
    It "Should check if a number is greater than or equal to another number" {
        # Arrange & Act
        $actual = 0
        $expected = 0

        # Assert
        $actual | Should -BeGreaterOrEqual $expected
    }

    It "Should check if a number is less than or equal to another number" {
        # Arrange & Act
        $actual = 1
        $expected = 0

        # Assert
        $actual | Should -BeLessOrEqual $expected
    }
}

# String Comparison Tests

Describe "String Comparison Tests" {
    It "Should check if a string matches a pattern" {
        # Arrange & Act
        $actual = 'word'
        $pattern = '*o*'

        # Assert
        $actual | Should -BeLike $pattern
    }

    It "Should check if a string matches an exact pattern" {
        # Arrange & Act
        $actual = 'WORD'
        $pattern = '*O*'

        # Assert
        $actual | Should -BeLikeExactly $pattern
    }
}

# String Matching Tests

Describe "String Matching Tests" {
    It "Should check if a string matches a regular expression pattern" {
        # Arrange & Act
        $actual = 'word'
        $pattern = '^w'

        # Assert
        $actual | Should -Match $pattern
    }

    It "Should check if a string matches an exact regular expression pattern" {
        # Arrange & Act
        $actual = 'Word'
        $pattern = '^w'

        # Assert
        $actual | Should -MatchExactly $pattern
    }
}

# Boolean Comparison Tests

Describe "Boolean Comparison Tests" {
    It "Should check if a value is true" {
        # Arrange & Act
        $actual = $true

        # Assert
        $actual | Should -BeTrue
    }

    It "Should check if a value is false" {
        # Arrange & Act
        $actual = $false

        # Assert
        $actual | Should -BeFalse
    }
}

# Array Containment Tests

Describe "Array Containment Tests" {
    It "Should check if an array contains a specific element" {
        # Arrange & Act
        $actual = @('red','yellow','green')
        $expected = 'green'

        # Assert
        $actual | Should -Contain $expected
    }
}

# Element Inclusion Tests

Describe "Element Inclusion Tests" {
    It "Should check if an element is in an array" {
        # Arrange & Act
        $actual = 'green'
        $expected = @('red','yellow','green')

        # Assert
        $actual | Should -BeIn $expected
    }
}

# Array Count Tests

Describe "Array Count Tests" {
    It "Should check if an array has a specific count" {
        # Arrange & Act
        $actual = @('red','yellow','green')
        $expectedCount = 3

        # Assert
        $actual | Should -HaveCount $expectedCount
    }
}

# Variable Type Tests

Describe "Variable Type Tests" {
    It "Should check if a variable is of a specific type" {
        # Arrange
        $variable = 'test'
        $expectedType = 'System.String'

        # Assert
        $variable | Should -BeOfType $expectedType
    }
}

# Object Type Tests

Describe "Object Type Tests" {
    It "Should check if a value is of a specific type (using string alias)" {
        # Arrange
        $value = 'test'
        $expectedType = 'string'

        # Assert
        $value | Should -BeOfType $expectedType
    }

    It "Should check if an object is of a specific type (using type literal)" {
        # Arrange
        $object = [pscustomobject]@{Property = 'foo'}
        $expectedType = [pscustomobject]

        # Assert
        $object | Should -BeOfType $expectedType
    }
}

# Parameter Have tests
Describe "Command Parameter Tests" {
    BeforeAll {
        function Get-Thing {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory)]
                [string]$MyParam
            )
        }
    }
    It "Should check if a command has a specific parameter with the expected properties" {
        # Assert
        Get-Command -Name 'Get-Thing' | Should -HaveParameter 'MyParam' -Type 'string' -Mandatory
    }
}

Describe "Command Parameter Tests" {
    BeforeAll {
        function Get-Thing {
            [CmdletBinding()]
            param(
            [Parameter()]
            [string]$MyParam = 'default'
            )
        }
    }
    It "Should check if a command has a specific parameter with the expected properties" {
        # Assert
        Get-Command -Name 'Get-Thing' | Should -HaveParameter 'MyParam' -DefaultValue 'default'
    }
}

# parameter set tests

Describe 'Parameters set' {
    BeforeAll {    
        function Get-Thing {
            [CmdletBinding()]
            param(
            [Parameter(ParameterSetName = 'MyParamSet',Mandatory)]
            [string]$MyParam
            )
        }
    }

    It 'Check parameterset value' {
        $commandToTest = 'Get-Thing'
        $paramToTest = 'MyParam'
        $parameterSetName = 'MyParamSet'
        $cmd = (Get-Command $commandToTest).Parameters[$paramToTest].Attributes
        $parameter = $cmd | Where-Object {
            $_.TypeId.Name -eq "ParameterAttribute" -and
            $_.ParameterSetName -eq $parameterSetName
        }
        $parameter.Mandatory | should -Be $true
    }
}

# File Content Tests

Describe "File Content Tests" {
    It "Should check if a file contains a specific value" {
        # Arrange
        $filePath = 'C:\foo.txt'
        $expectedContent = 'test'

        # Act
        Add-Content -Path $filePath -Value 'this is a test'

        # Assert
        $filePath | Should -FileContentMatch $expectedContent
    }
}

# File Content Tests

Describe "File Content Tests" {
    It "Should check if a file contains an exact match of a specific value" {
        # Arrange
        $filePath = 'C:\test.txt'
        $expectedContent = 'test'

        # Act
        Add-Content -Path $filePath -Value 'this is a TEST'

        # Assert
        $filePath | Should -FileContentMatchExactly $expectedContent
    }
}

Describe "File Content Tests" {
    It "Should check if a file contains a multiline pattern" {
        # Define the content to be added to the file
        $data = @"
        Line 1
        Line 2
        Line 3
"@

        # Add the content to the file
        Add-Content -Path 'C:\foo.txt' -Value $data

        # Define the pattern to match in the file content
        $pattern = "Line 1$([System.Environment]::NewLine)Line 2$([System.Environment]::NewLine)Line 3"

        # Assert that the file content matches the multiline pattern
        'C:\foo.txt' | Should -FileContentMatchMultiline $pattern
    }
}

#Exist

Describe "Folder Existence Tests" {
    It "Should check if a folder exists" {
        # Arrange
        $folderPath = 'C:\FolderDoesNotExist'

        # Act & Assert
        $folderPath | Should -Not -Exist
    }
}

Describe "Folder Existence Tests" {
    It "Should check if a folder exists" {
        # Arrange
        $folderPath = 'C:\foo.txt'

        # Act & Assert
        $folderPath | Should -Exist
    }
}

# throw

Describe "Exception Throwing Tests" {
    It "Should throw an exception" {
        # Arrange & Act
        $scriptBlock = { throw "total fail" }

        # Assert
        $scriptBlock | Should -Throw
    }
}

Describe "Exception Throwing Tests" {
    It "Should throw an exception with a specific message" {
        # Arrange & Act
        $scriptBlock = { throw "total fail" }
        $expectedExceptionMessage = "total fail"

        # Assert
        $scriptBlock | Should -Throw $expectedExceptionMessage
    }
}

Describe "Exception Throwing Tests" {
    It "Should throw an exception with a specific ErrorId" {
        # Arrange & Act
        $scriptBlock = { throw "total fail" }
        $expectedErrorId = 'total fail'

        # Assert
        $scriptBlock | Should -Throw -ErrorId $expectedErrorId
    }
}

Describe 'add-shouldoperator example'{
    BeforeAll{
        function HaveGreen {
            [Cmdletbinding()]
            param(
                [Parameter(ValueFromPipeline)]
                $ActualValue,
                [Parameter()]
                [bool]$Negate
            )
            process{
                $message = if ($Negate) {
                'We expected not to find green but we did find it'
                } 
                else {
                'We expected to find green but did not find it'
                }
                $result = [pscustomobject]@{
                    Succeeded = $Negate
                    FailureMessage = $message
                }
                if ($ActualValue -contains 'green') {
                    $result.Succeeded = -not $negate
                }
                $result
            }
        }
        Add-ShouldOperator -Name 'HaveGreen' -Test $Function:HaveGreen
    }

    it 'should have green' {
        'green' | Should -HaveGreen
    }
}

# because

describe 'my maths test' {
    it '1 should obviously be 2' {
    1 | should -be 2 -Because "I don't know maths"
    }
}

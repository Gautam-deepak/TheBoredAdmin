Describe -Tag 'Linux' 'Stop-MailDaemon' {
    BeforeAll {
        Write-Host -ForegroundColor Yellow "BeforeAll: Running before all tests..."
        # Code to run before all tests in this Describe block
    }

    BeforeEach {
        Write-Host -ForegroundColor Cyan "BeforeEach: Running before each test..."
        # Code to run before each test in this Describe block
    }

    It 'the script runs' {
        Write-Host -ForegroundColor Green "Running the script runs test..."
        # Code to compare the state to test with the real state
    }

    Context 'When the server is down' {
        It 'throws an exception' {
            Write-Host -ForegroundColor Magenta "Running the throws an exception test..."
            # Code to compare the state to test with the real state
        }
    }

    AfterEach {
        Write-Host -ForegroundColor Cyan "AfterEach: Running after each test..."
        # Code to run after each test in this Describe block
    }

    AfterAll {
        Write-Host -ForegroundColor Yellow "AfterAll: Running after all tests..."
        # Code to run after all tests in this Describe block
    }
}
<#
"BeforeAll" messages are displayed in yellow (-ForegroundColor Yellow).
"BeforeEach" messages are displayed in cyan (-ForegroundColor Cyan).
"the script runs" messages are displayed in green (-ForegroundColor Green).
"When the server is down" messages are displayed in magenta (-ForegroundColor Magenta).
"AfterEach" messages are displayed in cyan (-ForegroundColor Cyan).
"AfterAll" messages are displayed in yellow (-ForegroundColor Yellow).
#>
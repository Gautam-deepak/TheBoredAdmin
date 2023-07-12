describe 'should only run on Windows' {
    BeforeAll {
        $itParams = @{}
        if (-not $IsWindows) {
            $itParams.Skip = $true
        }
    }
    context 'Block A' {
        it @itParams 'This only runs on Windows' {
        $true | should -Be $true
        }
    }
}

describe 'should only run on Windows' {
    BeforeAll {
        $itParams = @{}
        if (-not $IsLinux) {
            $itParams.Skip = $true
        }
    }
    context 'Block A' {
        it @itParams 'This only runs on linux' {
        $true | should -Be $true
        }
    }
}

Describe "Runs only on when notepad is opened"{
    BeforeAll{
        $notepad=get-process -name notepad -ErrorAction SilentlyContinue
        $itParams = @{}
        if ($notepad -eq $null) {
            $itParams.Skip = $true
        }
        It @itParams "Check if notepad is open"{
            $true | should -be $true
        }
    }
}

Describe "Run only when service spooler is running"{
    BeforeAll{
        $itParams=@{}
        $servicestatus=get-service -name spooler | Select-Object -ExpandProperty Status
        if($servicestatus -eq "Stopped"){
            $itParams.Skip=$true
        }
    }
    It @itParams "Run when spooler is running"{
        $true | should -be $true
    }
}

# For enforcing test should run without skipping/pending
# Invoke-Pester -Path MyTests.Tests.ps1 -Strict
describe 'New-Thing' -Tag 'Modification' {
    it "New-thing Modification"{
        $true | should -be $true
    }
}
describe 'Set-Thing' -Tag 'Modification' {
    it "Set-thing Modification"{
        $true | should -be $true
    }
}
describe 'Get-ThingAttribute' -Tag 'ReadOnly' {
    it "Get-thingattribute readonly"{
        $true | should -be $true
    }
}
describe 'Get-Thing' -Tag 'ReadOnly' {
    it "Get-thing readonly"{
        $true | should -be $true
    }
}

describe 'Get-Thing' -Tag 'ReadOnly','Modification' {
    it "Get-thing readonly and Modification"{
        $true | should -be $true
    }
}
#Invoke-Pester -Path C:\Thing.Tests.ps1 -Tag 'Modification'
#Invoke-Pester -Path C:\Thing.Tests.ps1 -Tag 'readonly'
# Invoke-Pester -Path C:\Thing.Tests.ps1 -ExcludeTag 'Modification'
. .\mock2.ps1

Describe "mock get-stuff with random"{
    Mock get-random -MockWith { 5 } 
    Context "mocking get-stuff output"{
        It "Mock get-stuff random"{
            $expected=get-stuff -limit 70
            $expected | should -be 5
        }
    }
    It "Mock get-stuff with value"{
        $expected=get-stuff -limit 101
        $expected | should -be 100
    }    
}

Describe "How to mock a function" {
    Mock get-stuff -MockWith  { 10 }  -ParameterFilter { $limit -eq 30 }
    Mock get-stuff -MockWith  { 100 }  -ParameterFilter { $limit -eq 100 }
    it "should return 11" {
        get-otherStuff -limit 30 | Should -be 11
    }
    it "should return 101" {
        get-otherStuff -limit 100 | Should -be 101
    }
}

. .\mock2.ps1

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
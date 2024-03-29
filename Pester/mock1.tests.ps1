. .\mock1.ps1

Describe "How to mock a function" {
    Mock get-stuff { } 
    it "should return 1" {
        get-otherStuff | Should -be 1
    }
}

Describe "How to mock a function" {
    context 'Where get-stuff return nothing' {
        Mock get-stuff { }  
        it "should return 1" {
            get-otherStuff | Should -be 1
        }
    }
    context 'Where get-stuff return 5' {
        Mock get-stuff -MockWith { 5 } 
        it "should return 6" {
            get-otherStuff | Should -be 6
        }
    }
}

Describe "Mock random"{
    Mock get-random -mockwith { 5 }
    Context  get-stuff{
        it "get-stuff with random" {
            $expected=get-stuff
            $expected | should -be 5
        }
    }
}


. .\mock3.ps1

Describe "How to mock a function" {
    Mock get-item -MockWith {
        [pscustomobject]@{
            "Extension"         = "txt"
            "Length"            = 8655
            "LastAccessTime"    = "lundi 29 avril 2019 07:50:52"
        }
     }
    It "return txt" {
        get-fileExtension -filepath test.txt | Should -be "txt"
    }
}
Describe "test Error"{
    Mock Write-Error -MockWith { "Error" }
    get-fileExtension -filepath c:\fdsfd.txt | Should -be "Error"
}


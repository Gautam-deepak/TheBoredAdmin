
function Do-Something {
    param($Path)
    Get-Content -Path $Path 
    Get-Content -Path 'C:\SomeOtherPath.txt'    
}
function Set-File {
    param(
    [string]$Filename,
    [string]$path
    )
    If($Filename){
        New-Item -ItemType File -Path $path -Name $($Filename+".txt") -Force | Out-Null
        Set-Content -Path $path\$($Filename+".txt") -Value "Hello"
    }
    else{
        Write-Output "no file name defined"
    }
}
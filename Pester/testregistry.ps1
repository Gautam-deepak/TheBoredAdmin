function Get-RegPath($path, $key) {
    Get-ItemProperty -Path $path -Name $key | Select-Object -ExpandProperty $key
}
$ErrorActionPreference="stop"
function Test-LocalFile
{   
    [cmdletbinding(supportsshouldprocess)]
    param (
        [string]
        $filepath
    )
    try {
        $FileInfo = get-item -Path $filepath 
        if ($FileInfo.getType().Name -eq "FileInfo") {
            return $true
        }
    } catch {
        #throw "file does not exist"
        Write-Error -Message "$_"
    }
}
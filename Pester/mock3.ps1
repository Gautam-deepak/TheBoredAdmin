$ErrorActionPreference="Stop"
function get-fileExtension{
    param (
        [string]
        $filepath
    )
    try {
        $FileInfo = get-item -Path $filepath -ErrorAction Stop
        return $FileInfo.Extension
    } catch {
        Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
    }
}
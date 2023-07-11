function get-fileExtension
{
    param (
        [string]
        $filepath
    )
    try {
        $FileInfo = get-item -Path $filepath 
        return $FileInfo.Extension
    } catch {
        Write-Error -Message " Exception Type: $($_.Exception.GetType().FullName) $($_.Exception.Message)"
    }
}
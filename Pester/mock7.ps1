function Find-SqlServerServicePackInstaller {
    param(
        $Version
    )
    if ($Version -eq 2012) {
        [pscustomobject]@{
            Name = 'installername2012'
    }
    } 
    elseif ($Version -eq 2014) {
        [pscustomobject]@{
        Name = 'installername2014'
        }
    }
}
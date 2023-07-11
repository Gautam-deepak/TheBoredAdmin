function get-stuff {
    param (
        [int]
        $limit
    )
    if ($limit -gt 99) {
        return 100
    } else {
        return Get-Random -Maximum 10 -Minimum 1
    }   
}
function get-otherStuff {
    param (
        [int]
        $limit = 10
    )
    $stuff = get-stuff -limit $limit
    return $stuff + 1
}
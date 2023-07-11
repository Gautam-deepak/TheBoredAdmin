function get-stuff {
    return Get-Random -Maximum 10 -Minimum 1
}

function get-otherStuff {
    $stuff = get-stuff 
    return $stuff + 1
}
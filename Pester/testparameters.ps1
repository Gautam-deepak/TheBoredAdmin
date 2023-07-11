function Set-Computer {
    param($ComputerName)
    if ($ComputerName -like '*SRV') {
        ## Do something because it's a server
        'Did that thing to the server'
    } 
    else {
    ## Do something else because it's probably a client
        'Did that thing to the client'
    }
}
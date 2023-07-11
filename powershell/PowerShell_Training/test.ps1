$ErrorActionPreference="continue"

try {
    start-service -Name fdsfs 
    1/0
    write-host hello
}
catch {
    write-host "error happend , did not print first hello"
}
write-host "second hello"


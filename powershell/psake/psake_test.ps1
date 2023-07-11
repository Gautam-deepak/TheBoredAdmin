task Rebuild -depends Clean,build {
    "Rebuild"
}
task build{
    "Build"
}
task clean{
    'clean'
}
task default -depends Build
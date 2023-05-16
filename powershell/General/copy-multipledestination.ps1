#requires -version 5.1
#requires -module ThreadJob

Function Copy-ItemToMultiDestination {
    [CmdletBinding(
        SupportsShouldProcess,
        ConfirmImpact = 'Medium'
    )]
    [alias("cp2")]
    Param(
        [Parameter(
            Mandatory,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify a file system source path."
        )]
        [ValidateScript({ Test-Path $_ })]
        [string[]]$Path,
        [Parameter(
            Mandatory,
            Position = 1,
            ValueFromPipelineByPropertyName,
            HelpMessage = "Specify a file system destination."
        )]
        [ValidateScript({ Test-Path $_ })]
        [string[]]$Destination,
        [switch]$Container,
        [switch]$Force,
        [string]$Filter,
        [string[]]$Include,
        [string[]]$Exclude,
        [switch]$Recurse,
        [switch]$PassThru,
        [Parameter(ValueFromPipelineByPropertyName)]
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]$Credential
    )

    Begin {

        Write-Verbose "$((Get-Date).TimeOfDay) [BEGIN  ] Starting $($MyInvocation.Mycommand)"
        #initialize a list for thread jobs
        $jobs = [System.Collections.Generic.List[object]]::new()

    } #begin

    Process {
        [void]($PSBoundParameters.Remove("Destination"))

        foreach ($location in $Destination) {
            Write-Verbose "$((Get-Date).TimeOfDay) [PROCESS] Creating copy job"
            $PSBoundParameters.GetEnumerator() | ForEach-Object -Begin { $p = "Copy-Item" } -Process {
                if ($_.value -eq $True) {
                    $p += " -$($_.key)"
                }
                else {
                    $p += " -$($_.key) $($_.value)"
                }
            } -End {
                $p += " -destination $location"
            }

            Write-Verbose "$((Get-Date).TimeOfDay) [PROCESS] $p"
            $sb = [scriptblock]::Create($p)

            #Start-ThreadJob doesn't support -whatif
            if ($PSCmdlet.ShouldProcess($p)) {
                $j = Start-ThreadJob $sb
                #add each job to the list
                $jobs.add($j)
            }
        } #foreach location

    } #process

    End {
        If ($jobs) {
            Write-Verbose "$((Get-Date).TimeOfDay) [END    ] Processing $($jobs.count) thread jobs"
            $jobs | Wait-Job | Receive-Job
            $jobs | Remove-Job
        }

        Write-Verbose "$((Get-Date).TimeOfDay) [END    ] Ending $($MyInvocation.Mycommand)"

    } #end

} #end function Copy-ItemToMultiDestination
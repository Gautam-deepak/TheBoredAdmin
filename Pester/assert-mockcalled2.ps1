function Get-Total {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [int]$Number1,

        [Parameter(Mandatory = $true)]
        [int]$Number2
    )

    $total = $number1,$number2 | Measure-Object -AllStats | Select-Object -ExpandProperty Sum
    return $total
}

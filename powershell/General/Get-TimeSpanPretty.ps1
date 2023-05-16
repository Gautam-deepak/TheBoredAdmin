Function Get-TimeSpanPretty {
    <#
    .Synopsis
       Displays the time span between two dates in a single line, in an easy-to-read format
    .DESCRIPTION
       Only non-zero weeks, days, hours, minutes and seconds are displayed.
       If the time span is less than a second, the function display "Less than a second."
    .PARAMETER TimeSpan
       Uses the TimeSpan object as input that will be converted into a human-friendly format
    .EXAMPLE
       Get-TimeSpanPretty -TimeSpan $TimeSpan
       Displays the value of $TimeSpan on a single line as number of weeks, days, hours, minutes, and seconds.
    .EXAMPLE
       $LongTimeSpan | Get-TimeSpanPretty
       A timeline object is accepted as input from the pipeline. 
       The result is the same as in the previous example.
    .OUTPUTS
       String(s)
    .NOTES
       Last changed on 28 July 2022
    #>
        [CmdletBinding()]
        Param
        (
            # Param1 help description
            [Parameter(Mandatory,ValueFromPipeline)][ValidateNotNull()][timespan]$TimeSpan
        )
        Begin {}
        Process{
            # Initialize $TimeSpanPretty, in case there is more than one timespan in the input via pipeline
            [string]$TimeSpanPretty = ""
        
            $Ts = [ordered]@{
                Weeks   = [int]($TimeSpan.Days / 7)
                Days    = $TimeSpan.Days % 7
                Hours   = $TimeSpan.Hours
                Minutes = $TimeSpan.Minutes
                Seconds = $TimeSpan.Seconds
            } 
            # Process each item in $Ts (week, day, etc.)
            foreach ($i in $Ts.Keys){
                # Skip if zero
                if ($Ts.$i -ne 0) {
                    
                    # Append the value and key to the string
                    $TimeSpanPretty += "{0} {1}, " -f $Ts.$i,$i
                    
                } #Close if
        
            } #Close for
        
        # If the $TimeSpanPretty is not 0 (which could happen if start and end time are identical.)
        if ($TimeSpanPretty.Length -ne 0){
            # delete the last coma and space
            $TimeSpanPretty = $TimeSpanPretty.Substring(0,$TimeSpanPretty.Length-2)
        }
        else {
            
            # Display "Less than a second" instead of an empty string.
            $TimeSpanPretty = "Less than a second"
        }
        $TimeSpanPretty
        } # Close Process
        End {}
    } #Close function Get-TimeSpanPretty
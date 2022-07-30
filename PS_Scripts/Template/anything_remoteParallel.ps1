
# $Computers= selection of computers goes here 

$ErrorActionPreference="Stop"

$results=$computers | ForEach-Object -Parallel {

    If (test-connection -ComputerName $_ -Count 1 -Quiet)
    {
        Try {
           
            Invoke-Command -ComputerName $_ -ScriptBlock {
                # Command goes here
            }
            
            $status = "Success"
            $issue="No Error"

        } Catch {
            
            $status = "Failed"
            $issue=$($Error[0].exception.message)

        }

        Finally{
            $Error.Clear()
        }
    }
    else
    {   
        
        $status = "Unreachable"
        $issue="Destination host is not reachable"
    }
    
    [pscustomobject]@{
        'Computer'=$_
        'Status'=$status
        'Error'=$issue
        
    }

} -throttlelimit 100 -AsJob | Receive-Job -Wait -AutoRemoveJob

$results | export-csv -Path c:\Unreachable.csv -NoTypeInformation -Force
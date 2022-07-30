# Copy files based on their modification time 
# Only copy files that have been modified since the last time the script was run

#variables

$date=(get-date).AddDays(-9)

function copy-datewise {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $source_path,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $destination_path
    )
    
    $Source_files=Get-ChildItem -Path $source_path -Recurse -File
    $destination_files=Get-ChildItem -Path $destination_path -Recurse -File 

    foreach ($source_file in $Source_files) {
        foreach ($destination_file in $destination_files) {
            if (($source_file.Name -eq $destination_file.Name) -and ($source_file.LastWriteTime -le $date)) {
                Copy-Item -Path $destination_file.FullName -Destination $source_file.Directory -Force
            }
            else {
                Write-Host "File $source_file.Name has not been modified since last run"
            }
        }
        
    }

}

# Main

copy-datewise $source_path $destination_path
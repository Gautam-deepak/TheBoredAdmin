#!/bin/bash

#
# Author: Deepak Gautam, Om Prakash
# Date: June 15, 2023
# Description: This script performs rsync operation between local and destination directories and logs the differences.
#

serverlist=$1
sourcedir=$2
destdir=$3
logfile="script_log.txt"  # Specify the log file name and path

# Define the list of servers
servers=$(cat "$serverlist")

# Function to write output to log file
log_echo() {
    echo "$1" >> "$logfile"
    echo "$1"
}

# Redirect all echo statements to the log file
exec > >(while read -r line; do log_echo "$line"; done)

# Checking directories inside source directory

# Get a list of directories inside the sourcedir
files=$(find "$sourcedir" -mindepth 1 -maxdepth 2 -type d)

# Defining an array to store the folder names inside source directories
directories=()

# Extract the directory names from the file list
for file in $files; do
    directory="${file#"$sourcedir"}"
    directories+=("$directory")
done

# Iterate over the server list to check if directories exist, and if they do, check permissions

for server in $servers; do
    
    # Loop through each directory to perform checks
    for directory in "${directories[@]}"; do
        source_file="$sourcedir$directory"
        destination_file="$destdir$directory"

        if [ -d "$source_file" ]; then
        	
            # Retrieve source file permissions, owner, and group
            
            source_permission=$(stat -c '%a' "$source_file")
            
            source_user=$(stat -c '%U' "$source_file")
            
            source_group=$(stat -c '%G' "$source_file")
            

            # Check if the destination directory exists on the remote server
            if ssh "$server" [ -d "$destination_file" ]; then
                # Retrieve destination file permissions, owner, and group on the remote server
                
                destination_permission=$(ssh "$server" stat -c '%a' "$destination_file")
                
                destination_user=$(ssh "$server" stat -c '%U' "$destination_file")
                
                destination_group=$(ssh "$server" stat -c '%G' "$destination_file")
                

                # Compare permissions, owner, and group between source and destination
                if [ "$source_permission" != "$destination_permission" ]; then
                    log_echo "$server: Permission difference: Source - $source_permission , Destination - $destination_permission, Directory - $directory "
                fi

                if [ "$source_user" != "$destination_user" ]; then
                    log_echo "$server: User difference: Source - $source_user , Destination - $destination_user, Directory - $directory"
                fi

                if [ "$source_group" != "$destination_group" ]; then
                    log_echo "$server: Group difference: Source - $source_group , Destination - $destination_group, Directory - $directory"
                fi
            else
                log_echo "$server: Destination directory does not exist on remote server, Directory - $directory"
            fi
        else
            log_echo 'Source directory does not exist locally.'
        fi
    done
done 

# Making the changes

# Get the path of the first directory inside the sourcedir
paths=$(find "$sourcedir" -mindepth 1 -maxdepth 2 -type d | grep -v data)
# Iterate over the serverlist and rsync the path to the destination directory
for server in $servers; do
    echo "Syncing server: $server"
    for path in $paths; do    
        echo "Syncing path: $path"
        rsync -azv --exclude='/*/*/*/' --include='*/' --exclude='*' --exclude=cache/ "$path" root@"$server":"$destdir"/ >/dev/null 2>> error_log.txt
    done
done 

# Mail x
# echo "Report" | mailx -s "Latest Sensor directory sync report" -a ./script_log.txt emailid

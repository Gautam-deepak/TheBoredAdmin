#!/bin/bash


# Define the list of servers
servers=("server1" "server2" "server3")

# Define the source directory path
source_dir="/path/to/source/directory"

# Iterate over the servers
for server in "${servers[@]}"
do
    echo "Server: $server"

    # SSH into the server and execute the commands
    ssh "$server" "
        source_file=$source_dir
        destination_file='/path/to/destination/directory'

        if [ -d \$source_file ]; then
            source_permission=\$(stat -c '%a' \$source_file)
            source_user=\$(stat -c '%U' \$source_file)
            source_group=\$(stat -c '%G' \$source_file)

            if [ -d \$destination_file ]; then
                destination_permission=\$(ssh $server stat -c '%a' \$destination_file)
                destination_user=\$(ssh $server stat -c '%U' \$destination_file)
                destination_group=\$(ssh $server stat -c '%G' \$destination_file)

                if [ \$source_permission != \$destination_permission ]; then
                    echo 'Permission difference: Source - ' \$source_permission ', Destination - ' \$destination_permission
                fi

                if [ \$source_user != \$destination_user ]; then
                    echo 'User difference: Source - ' \$source_user ', Destination - ' \$destination_user
                fi

                if [ \$source_group != \$destination_group ]; then
                    echo 'Group difference: Source - ' \$source_group ', Destination - ' \$destination_group
                fi
            else
                echo 'Destination directory does not exist on remote server.'
            fi
        else
            echo 'Source directory does not exist locally.'
        fi
    "
    echo
done

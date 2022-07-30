#!/bin/bash
#! /usr/bin/env zsh
#!/usr/bin/env bash


# ======================================================================
# SCRIPT NAME: Pre-script.sh

# PURPOSE: Copy local user and group files from remote computer

# REVISION HISTORY:

# AUTHOR			DATE			DETAILS
# --------------------- --------------- --------------------------------

# Deepak Gautam			2021-5-27	  	Initial version

# ======================================================================

if [ -d "$3" ] 
then
    echo "Directory $3 already exists." 
else
    echo "Making a new Directory at $3"
	mkdir $3 # Making Directory for results
fi

for server in $(cat $1) ; do sshpass -p $2 ssh root@${server} "bash -s" < ./pre-script.sh ; done  # Loop to run the pre-script

for server in $(cat $1) ; do sshpass -p $2 scp root@${server}:/home/root/${server}-*.csv $3; done # Loop to copy the file created in pre-script into local linux

paste -d, $3/*-user.csv > $3/ListOfUsers.csv # Creating Final list of users 
echo "List of Users file is created under $3/ListOfUsers.csv"

paste -d, $3/*-group.csv > $3/ListOfGroups.csv # Creating Final list of groups
echo "List of Users file is created under $3/ListOfGroups.csv"

for server in $(cat $1) ; do rm $3/${server}-user.csv $3/${server}-group.csv; done # Removing extra files

echo "Extra files removed"
echo "Script finised"



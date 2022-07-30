#!/bin/bash
#! /usr/bin/env zsh
#!/usr/bin/env bash


# ======================================================================
# SCRIPT NAME: pre-script.sh

# PURPOSE: Create local user and local group file in remote computer

# REVISION HISTORY:

# AUTHOR			DATE			DETAILS
# --------------------- --------------- --------------------------------

# Deepak Gautam			2021-5-27	  	Initial version

# ======================================================================


# VARIABLE ASSIGNMENT
# Show hostname:
HOST=$(hostname) #HOSTNAME

# Current date:
CURRENTDATE=$(date +%F) # CURRENTDATE
# Host IP address:
IPADDRESS=$(hostname -I | cut -d ' ' -f1) # IPADDRESS 

# SHOW MESSAGES

echo "Working on ${IPADDRESS}"
echo "Doing SSH into ${IPADDRESS}"

awk -F':' '{ print $1}' /etc/passwd >test.csv # Taking output of list of users in a temp file
echo $HOSTNAME >test2.csv
cat test2.csv test.csv > ${IPADDRESS}-user.csv # File that contains list of users
rm test.csv

awk -F':' '{ print $1}' /etc/group >test.csv # Taking output of list of groups in a temp file
echo $HOSTNAME >test2.csv
cat test2.csv test.csv > ${IPADDRESS}-group.csv # File that contains list of groups

echo "Getting information from ${IPADDRESS}"

rm test.csv test2.csv # Removing extra files

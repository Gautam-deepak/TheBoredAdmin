#!/usr/bin/env bash
# write a bash script to take backup of certain file in a new directory

# Define variables for the color codes
red='\033[0;31m'
green='\033[0;32m'
cyan='\033[0;36m'
reset='\033[0m'

# Define backup parameters
BACKUP_DIR="/var/backups"
BACKUP_NAME="server_backup_$(date +%Y-%m-%d_%H-%M-%S)"
BACKUP_FILES="/var/www /etc/nginx /etc/mysql"

# Define functions

# This function takes a command to run as its first argument and an optional output file
# name as its second argument. It runs the command and captures any error output to the
# specified output file. It returns the exit status of the command.
run_command() {
  local cmd="$*"  # command to run, with all arguments included
  local output_file="/tmp/run_command_output.log"  # hardcoded output file name
  eval "$cmd" 2> "$output_file"  # run the command and capture error output to the output file
  local exit_status=$?  # capture the exit status of the command
  if [ $exit_status -ne 0 ]; then  # if the command exited with a non-zero status
    error_message=$(< "$output_file")  # read the error message from the output file
    echo -e "${red}Command '$cmd' exited with status $exit_status and message: $error_message${reset}"  # print the error message in red
    return 1
  fi
  rm -f "$output_file"  # delete the output file
  return $exit_status  # return the exit status of the command
}

# Main

echo -e "${cyan}Starting backup process...${reset}"

# Create backup directory if it does not exist
if [ ! -d "$BACKUP_DIR" ]; then
  echo -e "${green}Creating backup directory at $BACKUP_DIR...${reset}"
  run_command sudo mkdir -p "$BACKUP_DIR"
fi

# Create backup
echo -e "${green}Creating backup '$BACKUP_NAME'...${reset}"
run_command sudo tar -czvf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" "$BACKUP_FILES"

#backup completion
echo -e "${cyan}Backup process completed.${reset}"

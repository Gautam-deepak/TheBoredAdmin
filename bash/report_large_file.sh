#!/usr/bin/env bash

# Write a Bash script that identifies the largest files in a given path and outputs a report.

# Define variables for the color codes
red='\033[0;31m'
green='\033[0;32m'
cyan='\033[0;36m'
reset='\033[0m'

# functions

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

#Main
echo -e  "${green}------------------------------------------------------------------------------------------${reset}"
echo -e  "${cyan}           Welcome to command-line utility to report large files in a path    							${reset}"
echo -e  "${green}------------------------------------------------------------------------------------------${reset}"

find_large_file(){
  echo -e "${cyan}Enter directory to see largest file${reset}"
  read -r path
  if [ ! -d "$path" ]; then
    echo -e "${red} Directory doesn't exist${reset}"
    return 1
  fi
  run_command ls -l "$path" | sort -k 5 -rn | head | awk '{print $9,$5}'
}

find_large_file
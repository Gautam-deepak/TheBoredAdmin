#!/usr/bin/env bash

# Write a Bash script that recursively deletes all empty directories and files in a given path.

# Define variables for the color codes
red='\033[0;31m'
green='\033[0;32m'
cyan='\033[0;36m'
reset='\033[0m'
#yellow='\033[0;33m'
#blue='\033[0;34m'
#purple='\033[0;35m'
#gray='\033[0;37m'

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

del_empty_dir(){
	
	# This function prompts the user for a directory path and deletes all empty directories within it recursively.

	# Prompt the user to enter the path to the directory to be cleaned up.
	echo -e "${cyan}Enter the path to delete empty directories recursively.${reset}"
	read -r path

	# Display a warning message to the user before proceeding.
	echo -e "${red}Warning: All empty directories within the $path will be removed.${reset}"

	# Count the number of empty directories to be deleted.
	run_command 'count=$(find "$path" -empty -type d | wc -l)'

	# Check if there are any empty directories to delete.
	if [[ $count == 0 ]]; then
		# Inform the user that there are no empty directories to delete.
		echo -e "${green}There are no empty directories to delete.${reset}"
	else
		# Display the number of empty directories to be deleted.
		echo -e "${cyan}Number of empty directories to delete: $count${reset}"

		# Delete all empty directories recursively.
		find "$path" -empty -type d -delete
		
		# Check if the deletion was successful and inform the user accordingly.
		if [[ $? == 0 ]]; then
			echo -e "${green}Deleted empty directories successfully.${reset}"
		else
			echo -e "${red}Failed to delete empty directories.${reset}"
		fi
	fi
}

del_empty_file(){
	# This function prompts the user for a directory path and deletes all empty files within it recursively.

	# Prompt the user to enter the path to the directory to be cleaned up.
	echo -e "${cyan}Enter the path to delete empty files recursively.${reset}"
	read -r path

	# Display a warning message to the user before proceeding.
	echo -e "${red}Warning: All empty files within the $path will be removed.${reset}"

	# Count the number of empty files to be deleted.
	run_command 'count=$(find "$path" -empty -type f | wc -l)'

	# Check if there are any empty files to delete.
	if [[ $count == 0 ]]; then
		# Inform the user that there are no empty files to delete.
		echo -e "${green}There are no empty files to delete.${reset}"
	else
		# Display the number of empty files to be deleted.
		echo -e "${cyan}Number of empty files to delete: $count${reset}"

		# Delete all empty files recursively.
		find "$path" -empty -type f -delete

		# Check if the deletion was successful and inform the user accordingly.
		if [[ $? == 0 ]]; then
			echo -e "${green}Deleted empty files successfully.${reset}"
		else
			# Display an error message if the deletion was unsuccessful and include the error log.
			echo -e "${red}Failed to delete empty files"
		fi
	fi
}

echo -e  "${green}------------------------------------------------------------------------------------------${reset}"
echo -e  "           Welcome to command-line utility to delete empty directories and files							"
echo -e  "${green}------------------------------------------------------------------------------------------${reset}"

echo -e "${cyan}Please select one of the options to continue${reset}"
options=("delete empty directories" "delete empty files" "delete both files and directories" "quit")

# display the menu and get the user's choice

# This select loop displays a list of options to the user and calls the appropriate function based on their choice.

# Present a list of options to the user.
select choice in "${options[@]}"
do
	# Use a case statement to call the appropriate function based on the user's choice.
	case $choice in
		"delete empty directories")
			# Call the del_empty_dir function to delete all empty directories within a specified path.
			del_empty_dir
			;;
		"delete empty files")
			# Call the del_empty_file function to delete all empty files within a specified path.
			del_empty_file
			;;
		"delete both files and directories")
			# Call the del_empty_file function to delete all empty files within a specified path.
			del_empty_file

			# Call the del_empty_dir function to delete all empty directories within a specified path.
			del_empty_dir
			;;
		"quit")
			# Display a message and exit the loop if the user chooses to quit.
			echo -e "${red}quit${reset}"
			break
			;;
		*)
			# Display an error message if the user enters an invalid option.
			echo -e "${red}Invalid option${reset}"
			;;
	esac
done
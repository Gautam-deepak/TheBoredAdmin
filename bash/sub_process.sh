#!/bin/bash
# PostgreSQL parent process name
PARENT_PROCESS_NAME="postmaster"
value1="postgres: logger"
value2="postgres: checkpointer"
value3="postgres: background writer"
value4="postgres: walwriter"
value5="postgres: autovacuum launcher"
value6="postgres: stats collector"
value7="postgres: logical replication launcher"

 

# Output file path
OUTPUT_FILE="/root/mod_output.log"

 

# Get the process IDs of the PostgreSQL parent process
#PARENT_PROCESS_IDS=$(pgrep -x "${PARENT_PROCESS_NAME}")
PARENT_PROCESS_IDS=$(ps -ef|grep postmaster|grep -v "root"|awk '{print $2}')

 

# Loop through each parent process ID
for pid in ${PARENT_PROCESS_IDS}; do
    # Get the child process IDs associated with the parent process
    CHILD_PROCESS_IDS=$(pgrep -P "${pid}")

 

    # Check if there are any child processes
    if [ -n "${CHILD_PROCESS_IDS}" ]; then
        # If child processes are found, append the message to the output file
        echo "Child processes found for PID ${pid}:" >> "${OUTPUT_FILE}"
        ps -fp ${CHILD_PROCESS_IDS}|grep -i postgres | awk '{print $9,$10,$11,$12}' >> "${OUTPUT_FILE}"

 

echo >> "${OUTPUT_FILE}"
           else

 

      echo "No child processes running for postmaster"

 

    fi

 

 

    OUTPUT_FILE_CONTENT=$(cat "$OUTPUT_FILE")

 

    # Check if each value is present in the output file content

 

    if [[ ! "$OUTPUT_FILE_CONTENT" =~ $value1 ]]; then

 

      echo "$value1: down"

 

    else

 

      echo "$value1: up"

 

    fi

 

 


    if [[ ! "$OUTPUT_FILE_CONTENT" =~ $value2 ]]; then

 

      echo "$value2: down"

 

    else

 

      echo "$value2: up"

 

    fi

 

 


    if [[ ! "$OUTPUT_FILE_CONTENT" =~ $value3 ]]; then

 

      echo "$value3: down"

 

    else

 

      echo "$value3: up"

 

    fi

 

 


    if [[ ! "$OUTPUT_FILE_CONTENT" =~ $value4 ]]; then

 

      echo "$value4: down"

 

    else

 

      echo "$value4: up"

 

    fi

 

 


    if [[ ! "$OUTPUT_FILE_CONTENT" =~ $value5 ]]; then

 

      echo "$value5: down"

 

    else

 

      echo "$value5: up"

 

    fi

 

 


    if [[ ! "$OUTPUT_FILE_CONTENT" =~ $value6 ]]; then

 

      echo "$value6: down"

 

    else

 

      echo "$value6: up"

 

    fi

 

 

 

    if [[ ! "$OUTPUT_FILE_CONTENT" =~ $value7 ]]; then

 

      echo "$value7: down"

 

    else

 

      echo "$value7: up"

 

    fi
done
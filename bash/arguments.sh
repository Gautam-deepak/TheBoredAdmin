#!/bin/bash

# Create an array to store the command-line arguments
args=("$@")

# Access and print individual elements of the array
echo "Number of arguments passed: ${#args[@]}"
echo "All arguments:"
for arg in "${args[@]}"; do
    echo "$arg"
done
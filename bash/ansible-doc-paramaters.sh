#!/bin/bash

# Check if module name is provided as an argument
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <module_name>"
    exit 1
fi

# Display examples for the module
ansible-doc "$1" | awk '/OPTIONS/,/SEE ALSO:|ATTRIBUTES/ {if ($0 != "SEE ALSO:" && $0 != "ATTRIBUTES:") print}'

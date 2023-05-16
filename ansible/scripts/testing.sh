#!/bin/bash
echo "Received argument: $1"
IFS=',' read -ra groups <<< "$1"
echo "Split groups: ${groups[@]}"
for group in "${groups[@]}"; do
    echo "Running Host Group - ${group}"
    ansible-playbook /var/lib/awx/projects/win_ping.yml -i /var/lib/awx/projects/inventory.yml --limit "${group}" 
done

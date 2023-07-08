#!/bin/bash

working_dir="/mnt/c/Users/abylc/terraform/p1/p1_source"
log_file="output.log"

# Change directory to the working directory
cd "$working_dir" || exit

# Run terraform apply and save the output to the log file
echo "Running: terraform apply"
terraform apply -input=yes >> "$log_file" 2>&1

# Run ansible-inventory and save the output to the log file
echo "Running: ansible-inventory"
ansible-inventory -i inventory.yml --graph --vars >> "$log_file" 2>&1

# Run ansible-playbook (docker) and save the output to the log file
echo "Running: ansible-playbook (docker)"
ansible-playbook -i inventory.yml docker.yml -input=yes >> "$log_file" 2>&1

# Run ansible-playbook (jenkins) and save the output to the log file
echo "Running: ansible-playbook (jenkins)"
ansible-playbook -i inventory.yml jenkins.yml >> "$log_file" 2>&1

echo "Commands executed successfully. Output saved to $log_file"
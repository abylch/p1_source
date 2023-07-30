# Terraform Project 1

This project aims to create a complete DevOps work environment by integrating several tools into an EC2 instance on AWS using Terraform and Ansible. The infrastructure setup includes creating a VPC, a public subnet, a security group, a route table, a key pair, and an internet gateway. Additionally, Route 53 will be added to the architecture. Furthermore, an EventBridge will be implemented to automatically turn on and off the EC2 instance at specific times, and alerts will be configured to notify when the EC2 instance is turned on or off using SNS and CloudWatch. Finally, Ansible will be used to install Jenkins and Docker on the EC2 instance.

## Steps:

## Using Terraform
- Create a VPC
- Create 1 Public Subnet
- Create Security group
- Create Route table
- Create Keypair
- Create Internet Gateway
- Create Event Bridge Scheduler
- Create SNS Topic Subscription
- Create Create CloudWatch Event

![Alt text](http://abraham.bylch.com/img/sns_topic_ec2_state.PNG "ansible")

## Using Ansible
- Create an ansible Playbook that will install on the EC2 the CI/CD tool Jenkins on port 8080.
- Create an ansible Playbook that will Install on the same Ec2 docker engine.

![Alt text](http://abraham.bylch.com/img/terraform_ansible_module.png "terraform")

## Requirements

To successfully execute this project, you need to have the following prerequisites:

- AWS account credentials with appropriate permissions.
- Terraform installed on your local machine.
- Ansible installed on your local machine.

## Steps:

## WSL - Linux on Windows installation
Open windows terminal
wsl --list -o
wsl –install
user: ubuntu
pass:
sudo su
apt-get update
lsb_release -a

## ANSIBLE installation
apt-get install ansible

## TERRAFORM installation
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg

gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update
sudo apt-get install terraform


## Terraform Collection for Ansible Automation Platform
In ubuntu terminal:
ansible-galaxy collection install cloud.terraform
https://galaxy.ansible.com/cloud/terraform
after installation, create a inventory.yaml file and add to link in the first line: "plugin: cloud.terraform.terraform_provider"


note: More information will follow....... 

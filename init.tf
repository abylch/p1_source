terraform {
  required_providers {
    ansible = {
      version = "~> 1.1.0"
      source  = "ansible/ansible"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.5.0"
    }
  }
}

provider "ansible" {}

provider "aws" {
  region = "us-west-1"
}

provider "tls" {}

# backup the state file
# backend "s3" {
#     bucket = "terra-bucket"s
#     key    = "aws-bucket-demo1.tfstate"
#     region = "us-west-1"
# }


# Configure the AWS Provider

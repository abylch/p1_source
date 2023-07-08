variable "aws_region" {
    default = "us-west-1"
}

variable "bucket_name" {
    default = "terra-bucket"
}

variable "vpc_name" {
    default = "terra-vpc"
}

variable "terra_sg" {
    default = "terra-sg"
}

variable "acl_value" {
    default = "private"
}

variable "ec2_instance_type" {
    default = "t2.micro"
}

# type value
variable "availability_zone" {
  description = "The  availability zone"
  type        = map(string)
  default = {
    a = "us-west-1a"
    c = "us-west-1c"
  }
}

variable "terra_ec2" {
    default = "terra-ec2"
}

variable "aws_region" {
  description = "AWS region to reploy to"
  default = "eu-central-1"
}

variable "ami_id" {
  description = "AMI ID to use for the instance"
  default = "ami-02003f9f0fde924ea"
  }

variable "instance_type" {
  description = "Type of EC2 instance"
  default = "t2.micro"
}



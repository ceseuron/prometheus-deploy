variable "aws_vpc_id" {
  type        = string
  description = "The AWS VPC ID."
}

variable "aws_region" {
  type        = string
  description = "The AWS region."
}

variable "private_subnets" {
  type        = list(string)
  description = "The list of private subnet IDs."
  default     = null
}

variable "public_subnets" {
  type        = list(string)
  description = "The list of public subnet IDs."
  default     = null
}

variable "instance_count" {
  type        = number
  description = "The total number of EC2 instances to create."
}

variable "aws_ec2_instance_type" {
  type        = string
  default     = "t2.micro"
  description = "The AWS instance type."
}

variable "aws_ec2_name" {
  type        = string
  description = "The name of the EC2 instance."
}

variable "aws_ec2_create_spot_instance" {
  type        = bool
  default     = false
  description = "Specify whether or not to use AWS spot instances."
}

variable "aws_ec2_spot_price" {
  type        = string
  default     = "0.60"
  description = "The AWS spot price."
}

variable "aws_ec2_spot_type" {
  type        = string
  default     = "persistent"
  description = "The spot instance type."
}

variable "aws_ec2_disk_size" {
  type        = number
  default     = 20 #GB
  description = "The size of the root disk."
}

variable "aws_ec2_disk_type" {
  type        = string
  default     = "gp3"
  description = "The type of the disk."
}

variable "aws_ec2_disk_delete_on_terminate" {
  type        = bool
  default     = true
  description = "Determine if the root disk should be deleted or not."
}

variable "aws_secret_name" {
  type        = string
  description = "The name of the AWS Secrets Manager secret containing the SSH keypair for EC2."
}

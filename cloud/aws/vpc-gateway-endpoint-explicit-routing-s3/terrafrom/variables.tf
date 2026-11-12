variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.16.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.16.16.0/20"
}

variable "private_subnet_cidr" {
  type    = string
  default = "10.16.32.0/20"
}

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

variable "vpc_ipv4_cidr" {
  description = "IPv4 CIDR block for the VPC"
  type        = string
  default     = "10.16.0.0/16"
}

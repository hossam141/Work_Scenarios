variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
  default     = "production"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.16.0.0/16"
}

variable "private_subnets_cidr" {
  type    = list(string)
  default = ["10.16.32.0/20", "10.16.48.0/20"]
}
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

variable "vpc_a_cidr" {
  type    = string
  default = "10.16.0.0/16"
}

variable "vpc_b_cidr" {
  type    = string
  default = "10.17.0.0/16"
}

variable "vpc_c_cidr" {
  type    = string
  default = "10.18.0.0/16"
}
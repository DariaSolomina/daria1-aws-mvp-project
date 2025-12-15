# Variables for the VPC module

variable "name" {
  description = "Name of the VPC"
  default     = "mvp-vpc"
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  description = "List of CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets" {
  description = "List of CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "env" {
  description = "Environment for the VPC (e.g., dev, prod)"
}

variable "azs" {
  default = ["us-west-2a", "us-west-2b"]
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Project     = "Terraform-MVP"
  }
}
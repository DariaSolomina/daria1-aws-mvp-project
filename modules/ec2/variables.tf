# Public subnet where the EC2 instance is deployed
variable "public_subnet_id" {
  description = "Public subnet ID to deploy EC2 instance"
  type        = string
}

# VPC ID used for creating resources
variable "vpc_id" {
  default = "vpc-0624f7e8067b54311"
}

# Instance type (e.g., t3.micro)
variable "instance_type" {
  description = "Type of EC2 instance to launch"
  type        = string
  default     = "t3.micro"
}

# AMI ID for the EC2 instance
variable "ami" {
  description = "Amazon Machine Image ID for the EC2"
  type        = string
}

# Name of SSH key pair to access the instance
variable "key_name" {
  description = "SSH key name for EC2"
  type        = string
  default     = null
}

variable "allowed_ssh_ips" {
  description = "List of allowed IP addresses for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Replace this with specific IPs if needed, e.g., ["192.168.1.1/32"] (for more secure access).
}

# Common tags applied to all resources
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "terraform-mvp"
  }
}

# Name prefix for resources
variable "name_prefix" {
  description = "Prefix to apply to resource names"
  type        = string
  default     = "terraform"
}

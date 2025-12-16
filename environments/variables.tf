variable "region" {
  default     = "us-west-2"
  type        = string
  description = "The AWS region where resources will be deployed"
}

variable "env" {
  description = "The environment for tagging resources (e.g., dev, prod)"
}

variable "ami" {
  default     = "ami-061b09f4833e8c74a"
  type        = string
  description = "The Amazon Machine Image ID"
}

variable "instance_type" {
  description = "Instance type for the EC2 instance (e.g., t2.micro, t3.micro)"
  type        = string
  default     = "t3.micro" # Provide a default value, or remove this if you plan to pass it explicitly
}

variable "key_name" {
  description = "Name of the SSH key pair to use for accessing the EC2 instance"
  default     = null # Default to 'null' meaning no key pair is specified
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
  default     = "Admin123456!"
}

variable "db_username" {
  description = "The username for the RDS database"
  type        = string
  default     = "admin" # Replace with a prompt or a more secure value in production
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "Allocated storage capacity for the RDS instance"
  default     = 20
}
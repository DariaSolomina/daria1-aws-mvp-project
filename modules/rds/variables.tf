variable "vpc_id" {
  description = "VPC ID where RDS will be deployed"
  type        = string
}

variable "db_subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID of the EC2 instance"
  type        = string
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
}

variable "db_password" {
  description = "Password for the RDS database"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}

variable "db_allocated_storage" {
  description = "The amount of allocated storage for the RDS instance"
  type        = number
  default     = 20
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}

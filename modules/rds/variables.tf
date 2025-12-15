variable "db_password" {
  description = "Password for the RDS database"
  sensitive   = true
  type        = string
}

variable "db_allocated_storage" {
  default     = 20
  type        = number
  description = "The amount of allocated storage for the RDS instance"
}

variable "db_subnet_ids" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "vpc_id" {
  default = "vpc-0624f7e8067b54311"
}

variable "app_sg_id" { # Security group ID of the EC2 instance (app server). This allows the database to accept traffic only from the EC2.
  type = string
}

variable "private_subnets" {
  description = "List of private subnet IDs for RDS"
  type        = list(string)
}

variable "tags" {
  description = "Tags for all resources"
  type        = map(string)
  default     = {}
}

variable "db_username" {
  description = "Username for the RDS database"
  type        = string
}

variable "db_instance_class" {
  description = "RDS instance type"
  type        = string
  default     = "db.t3.micro"
}
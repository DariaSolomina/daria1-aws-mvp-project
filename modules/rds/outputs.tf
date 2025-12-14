output "endpoint" {
  value = aws_db_instance.db.endpoint # Reference the RDS endpoint
  description = "The endpoint for the RDS database"
}

output "db_name" {
  value = aws_db_instance.db.db_name # Name of the database (may be null if db_name not set)
}

output "db_username" {
  value = aws_db_instance.db.username # Username used to connect to the database (admin)
  sensitive   = true
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id # Security group protecting the RDS instance
}

output "multi_az" {
  value       = aws_db_instance.db.multi_az #Whether the RDS instance has Multi-AZ enabled
}
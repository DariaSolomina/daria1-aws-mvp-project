output "ec2_public_ip" {
  value = module.compute.ec2_public_ip #The public IP address of the EC2 instance.
}

output "ec2_public_dns" {
  value = module.compute.ec2_public_dns #The public DNS name for accessing the EC2 instance over the internet.
}

output "rds_endpoint" {
  value = module.database.endpoint #The connection endpoint (hostname) for the RDS database.
}

output "db_username" {
  value     = module.database.db_username #The username for connecting to the RDS database.
  sensitive = true
}

output "s3_bucket_name" {
  value = module.storage.bucket_name #The name of the application's S3 bucket.
}

output "vpc_id" {
  value       = "vpc-0624f7e8067b54311"
  description = "The ID of the VPC"
}

output "public_subnets" {
  value       = module.network.public_subnets
  description = "List of IDs of public subnets"
}

output "private_subnets" {
  value       = module.network.private_subnets
  description = "List of IDs of private subnets"
}
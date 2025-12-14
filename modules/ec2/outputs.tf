output "instance_id" { # ID of the EC2 instance
  value = aws_instance.web.id
}

output "ec2_public_ip" { # Public IP for accessing the instance
  value = aws_instance.web.public_ip
}

output "ec2_public_dns" { # DNS name for browser access
  value = aws_instance.web.public_dns
  sensitive = false
}

output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_profile.name
  description = "IAM instance profile name attached to EC2 instance"
}

output "iam_role_name" {
  value = aws_iam_role.ec2_s3_role.name
  description = "IAM role attached to EC2 instance for S3 and CloudWatch access"
}

output "sg_id" {
  description = "The ID of the security group attached to the EC2 instance"
  value       = aws_security_group.ec2_sg.id
}

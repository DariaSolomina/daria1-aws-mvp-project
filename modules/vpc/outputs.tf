output "vpc_id" {
  value       = "vpc-0624f7e8067b54311"
  description = "The ID of the VPC"
}

output "igw_id" {
  value       = aws_internet_gateway.this.id
  description = "The ID of the Internet Gateway associated with the VPC"
}

output "public_subnets" {
  value       = aws_subnet.public[*].id
  description = "List of IDs of public subnets"
}

output "private_subnets" {
  value = aws_subnet.private[*].id # Export subnet IDs created by `aws_subnet.private`
  description = "List of IDs for private subnets"
}

resource "aws_security_group" "ec2" {
  name        = "${var.name}-ec2-sg"
  description = "Security group for EC2 instances"
  vpc_id      = aws_vpc.this.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow all IPs
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ec2_security_group" {
  description = "The ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}
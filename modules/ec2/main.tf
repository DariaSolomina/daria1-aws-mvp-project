# ---------
# Security Group
# ---------

resource "aws_security_group" "ec2_sg" {
  vpc_id      = "vpc-0624f7e8067b54311" # Update to the EC2 instance's VPC ID
  name        = "compute-web-sg"
  description = "Allow web server traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH access; restrict this in production
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTP access
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # HTTPS access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }

  tags = {
    Name = "compute-web-sg"
  }
}

########################################
# IAM Role for EC2
########################################
resource "aws_iam_role" "ec2_s3_role" {
  name = "ec2-s3-access-role"

  # Trust relationship: allows EC2 to assume this IAM role.
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach policies for S3 access
resource "aws_iam_role_policy_attachment" "s3_access_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# Attach policies for CloudWatch monitoring
resource "aws_iam_role_policy_attachment" "cloudwatch_access_policy" {
  role       = aws_iam_role.ec2_s3_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

########################################
# IAM Instance Profile
########################################
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-profile"
  role = aws_iam_role.ec2_s3_role.name
}

########################################
# EC2 Instance Configuration
########################################
resource "aws_instance" "web" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id # Public Subnet ID
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = "ec2_profile" # Attach IAM instance profile

  tags = {
    Name = "web-server"  
  }

  root_block_device {
    encrypted = true
  }
}
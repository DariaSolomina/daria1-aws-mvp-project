# ---------------------------------------
# RDS Subnet Group
# ---------------------------------------

resource "aws_db_subnet_group" "db_group" {
  name       = "rds-subnet-group"
  subnet_ids = [
    "subnet-03e0487620591edf2",
    "subnet-02ab0a7ae6f6b0143",
    "subnet-00e3e33090e7f8d89"
    ]
  description = "Subnet group for RDS in VPC vpc-0624f7e8067b54311"
  tags = {
    Name = "rds-db-subnet-group"
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_username}-rds-subnet-group"
  subnet_ids = var.private_subnets

  tags = merge(var.tags, { "Name" = "${var.db_username}-rds-subnet-group" })
}

# ---------------------------------------
# RDS Security Group
# ---------------------------------------

resource "aws_security_group" "db_sg" {
  vpc_id      = "vpc-0624f7e8067b54311"
  description = "Allow application access to RDS"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_sg_id] # Allow traffic from EC2 security group
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------------------------------------
# RDS Instance
# ---------------------------------------

resource "aws_db_instance" "db" {
  allocated_storage    = var.db_allocated_storage
  engine               = "postgres"
  engine_version       = "12.7"
  instance_class       = var.db_instance_class
  username             = var.db_username
  password             = var.db_password
  skip_final_snapshot  = true
  storage_encrypted    = true
  multi_az             = false
  db_subnet_group_name = aws_db_subnet_group.db_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
    Name = "MVP RDS Instance"
  }
}
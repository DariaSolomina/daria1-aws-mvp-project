# ---------------------------------------
# RDS Subnet Group
# ---------------------------------------

resource "aws_db_subnet_group" "this" {
  name       = "${var.db_username}-rds-subnet-group"
  subnet_ids = var.db_subnet_ids

  tags = merge(var.tags, { "Name" = "${var.db_username}-rds-subnet-group" })
}

# ---------------------------------------
# RDS Security Group
# ---------------------------------------

resource "aws_security_group" "db_sg" {
  vpc_id      = var.vpc_id
  description = "Allow application access to RDS"

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, { "Name" = "rds-security-group" })
}

# ---------------------------------------
# RDS Instance
# ---------------------------------------

resource "aws_db_instance" "db" {
  allocated_storage      = var.db_allocated_storage
  engine                 = "postgres"
  engine_version         = "12.7"
  instance_class         = var.db_instance_class
  username               = var.db_username
  password               = var.db_password
  skip_final_snapshot    = true
  storage_encrypted      = true
  multi_az               = false
  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = merge(var.tags, { "Name" = "rds-instance" })
}

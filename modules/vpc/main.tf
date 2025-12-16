# ---------------------------------------
# VPC
# ---------------------------------------
resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(var.tags, {
    Name        = var.name
    Environment = var.env
    Project     = "MVP"
  })
}

# ---------------------------------------
# Internet Gateway
# ---------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.name}-igw"
    Environment = var.env
  })
}

# ---------------------------------------
# Public Subnets
# ---------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name        = "${var.name}-public-subnet-${count.index}"
    Environment = var.env
  })
}

# ---------------------------------------
# Private Subnets
# ---------------------------------------
resource "aws_subnet" "private" {
  count = length(var.private_subnets)

  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(var.tags, {
    Name        = "${var.name}-private-subnet-${count.index}"
    Environment = var.env
  })
}

# ---------------------------------------
# Public Route Table
# ---------------------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.name}-public-rt"
    Environment = var.env
  })
}

# ---------------------------------------
# Public Route Table Association
# ---------------------------------------
resource "aws_route_table_association" "public_assoc" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# ---------------------------------------
# Route for Internet Access
# ---------------------------------------
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

# ---------------------------------------
# Private Route Table
# ---------------------------------------
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.name}-private-rt"
    Environment = var.env
  })
}

# ---------------------------------------
# Private Route Table Association
# ---------------------------------------
resource "aws_route_table_association" "private_assoc" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

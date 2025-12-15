resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = var.name
    Environment = var.env #Use 'env' variable here
    Project     = "MVP"
  }
}

# ---------------------------------------
# Internet Gateway
# ---------------------------------------
resource "aws_internet_gateway" "this" {
  vpc_id = "vpc-0624f7e8067b54311"
  tags = {
    Name        = "${var.name}-igw"
    Environment = var.env #Use 'env' variable here
  }
}

# ---------------------------------------
# Public Subnets
# ---------------------------------------
resource "aws_subnet" "public" {
  count = length(var.public_subnets)

  vpc_id                  = "vpc-0624f7e8067b54311"
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.name}-public-subnet-${count.index}"
    Environment = var.env # Use 'env' variable here
  }
}

# ---------------------------------------
# Private Subnets
# ---------------------------------------
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.azs[count.index]
  vpc_id            = "vpc-0624f7e8067b54311"

  tags = {
    Name = "${var.name}-private-subnet-${count.index}"
  }
}

# ---------------------------------------
# Public Route Table
# ---------------------------------------
resource "aws_route_table" "public" {
  vpc_id = "vpc-0624f7e8067b54311"

  tags = {
    Name        = "${var.name}-public-rt"
    Environment = var.env # Use 'env' variable here
  }
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

resource "aws_nat_gateway" "gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
}

resource "aws_eip" "nat" {
  domain = "vpc"
  tags   = var.tags
}
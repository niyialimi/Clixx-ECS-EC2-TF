#==== The VPC ======#
resource "aws_vpc" "clixx_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "clixx_vpc_tf"
  }
}

#==== Public Subnets for Load Balancer and Bastion Server ======#
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.clixx_vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = element(var.public_subnets_names, count.index)
  }
}

#==== Private Subnets Application Server ======#
resource "aws_subnet" "private_server_subnet" {
  vpc_id                  = aws_vpc.clixx_vpc.id
  count                   = length(var.private_subnets_server_cidr)
  cidr_block              = element(var.private_subnets_server_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = element(var.private_subnets_server_names, count.index)
  }
}

#==== Private Subnets RDS Database ======#
resource "aws_subnet" "private_rds_subnet" {
  vpc_id                  = aws_vpc.clixx_vpc.id
  count                   = length(var.private_subnets_rds_cidr)
  cidr_block              = element(var.private_subnets_rds_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = false
  tags = {
    Name = element(var.private_subnets_rds_names, count.index)
  }
}

#==== Internet gateway for the public subnets ======#
resource "aws_internet_gateway" "clixx_igw" {
  vpc_id = aws_vpc.clixx_vpc.id
  tags = {
    Name = "Clixx_igw_Tf"
  }
}

#====== Elastic IP for NAT Gateway ======#
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.clixx_igw]
}

#====== NAT ======#
resource "aws_nat_gateway" "clixx_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on    = [aws_internet_gateway.clixx_igw]
  tags = {
    Name = "Clixx_NAT_Tf"
  }
}

#====== Routing table for public subnet ======#
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.clixx_vpc.id
  tags = {
    Name = "clixx_public-route-table"
  }
}

#====== Routing table for private subnet ======#
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.clixx_vpc.id
  tags = {
    Name = "clixx_private-route-table"
  }
}

#====== Add route for Public route table to Internet Gateway ======#
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.clixx_igw.id
}

#====== Add route for Private route table to NAT Gateway ======#
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.clixx_nat.id
}

#====== Route table associations to Public Subnets ======#
resource "aws_route_table_association" "public_internet" {
  count          = length(var.public_subnets_cidr)
  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_rt.id
}

#====== Route table associations to Private Subnets ======#
resource "aws_route_table_association" "private_internet_server" {
  count          = length(var.private_subnets_server_cidr)
  subnet_id      = element(aws_subnet.private_server_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}

#====== Route table associations to Private Subnets ======#
resource "aws_route_table_association" "private_internet_rds" {
  count          = length(var.private_subnets_rds_cidr)
  subnet_id      = element(aws_subnet.private_rds_subnet.*.id, count.index)
  route_table_id = aws_route_table.private_rt.id
}
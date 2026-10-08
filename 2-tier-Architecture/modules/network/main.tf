resource "aws_vpc" "this" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

resource "aws_internet_gateway" "pub" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

resource "aws_subnet" "public" {
  vpc_id = aws_vpc.this.id
  count  = length(var.public_subnet_cidrs)

  cidr_block        = var.public_subnet_cidrs[count.index]
  availability_zone = var.availability_zone[count.index]

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-${count.index}"
  }
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.this.id
  count  = length(var.private_subnet_cidrs)

  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zone[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-private-${count.index}"
  }
}

resource "aws_eip" "eip" {
  count  = length(var.public_subnet_cidrs)
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "pri" {
  count = length(var.public_subnet_cidrs)

  allocation_id = aws_eip.eip[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = {
    Name = "${var.project_name}-ngw-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  count  = length(var.public_subnet_cidrs)

  tags = {
    Name = "${var.project_name}-public-rt-${count.index}"
  }

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.pub.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id
  count  = length(var.private_subnet_cidrs)

  tags = {
    Name = "${var.project_name}-private-rt-${count.index}"
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.pri[count.index].id
  }
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnet_cidrs)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnet_cidrs)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}
resource "aws_vpc" "first-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "dev-vpc"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.first-vpc.id

  tags = {
    Name = "dev-gw"
  }
}

resource "aws_route_table" "r" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "dev-route-table"
  }
}


# Public Subnet 1 - ap-south-1a - 10.0.1.0/24

resource "aws_subnet" "public_subnet-1" {
  vpc_id                  = aws_vpc.first-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet 1"
  }
}

resource "aws_route_table_association" "p1" {
  subnet_id      = aws_subnet.public_subnet-1.id
  route_table_id = aws_route_table.r.id
}


# Public Subnet 2 - ap-south-1b - 10.0.2.0/24

resource "aws_subnet" "public_subnet-2" {
  vpc_id                  = aws_vpc.first-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public subnet 2"
  }
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public_subnet-2.id
  route_table_id = aws_route_table.r.id
}


# Nat Gateway 1

resource "aws_eip" "eip1" {
  vpc = true
}

resource "aws_nat_gateway" "gw1" {
  depends_on = [
    aws_internet_gateway.gw,
  ]
  allocation_id = aws_eip.eip1.id
  subnet_id     = aws_subnet.public_subnet-1.id
}

resource "aws_route_table" "nat_rt_1" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw1.id
  }

  tags = {
    Name = "nat-route-table-1"
  }
}


# private_subnet 3 - ap-south-1a - 10.0.3.0/24

resource "aws_subnet" "private_subnet-3" {
  vpc_id                  = aws_vpc.first-vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "private subnet 3"
  }
}

resource "aws_route_table_association" "p3" {
  subnet_id      = aws_subnet.private_subnet-3.id
  route_table_id = aws_route_table.nat_rt_1.id
}

# private_subnet 5 - ap-south-1a - 10.0.5.0/24

resource "aws_subnet" "private_subnet-5" {
  vpc_id                  = aws_vpc.first-vpc.id
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "ap-south-1a"

  tags = {
    Name = "private subnet 5"
  }
}

resource "aws_route_table_association" "p5" {
  subnet_id      = aws_subnet.private_subnet-5.id
  route_table_id = aws_route_table.nat_rt_1.id
}



# Nat Gateway 2

resource "aws_eip" "eip2" {
  vpc = true
}

resource "aws_nat_gateway" "gw2" {
  depends_on = [
    aws_internet_gateway.gw,
  ]
  allocation_id = aws_eip.eip2.id
  subnet_id     = aws_subnet.public_subnet-2.id
}

resource "aws_route_table" "nat_rt_2" {
  vpc_id = aws_vpc.first-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.gw2.id
  }

  tags = {
    Name = "nat-route-table-2"
  }
}


# private_subnet 4 - ap-south-1b - 10.0.4.0/24

resource "aws_subnet" "private_subnet-4" {
  vpc_id                  = aws_vpc.first-vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "private subnet 4"
  }
}

resource "aws_route_table_association" "p4" {
  subnet_id      = aws_subnet.private_subnet-4.id
  route_table_id = aws_route_table.nat_rt_2.id
}

# private_subnet 6 - ap-south-1b - 10.0.6.0/24

resource "aws_subnet" "private_subnet-6" {
  vpc_id                  = aws_vpc.first-vpc.id
  cidr_block              = "10.0.6.0/24"
  availability_zone       = "ap-south-1b"

  tags = {
    Name = "private subnet 6"
  }
}

resource "aws_route_table_association" "p6" {
  subnet_id      = aws_subnet.private_subnet-6.id
  route_table_id = aws_route_table.nat_rt_2.id
}
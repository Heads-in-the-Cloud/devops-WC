resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name = "${var.vpc_name}"
  }
}


resource "aws_subnet" "private-subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet1_cidr_block
  availability_zone = var.az_1
  tags = {
    Name = "private-subnet-1-WC"
  }

}


resource "aws_subnet" "private-subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet2_cidr_block
  availability_zone = var.az_2

  tags = {
    Name = "private-subnet-2-WC"
  }

}

resource "aws_subnet" "public-subnet1" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet3_cidr_block
  availability_zone = var.az_1
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-1-WC"
  }

}

resource "aws_subnet" "public-subnet2" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet4_cidr_block
  availability_zone = var.az_2
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-2-WC"
  }

}


resource "aws_internet_gateway" "internet-gw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.internet_gw_name}"
  }
}



resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.internet-gw.id
  }

  tags = {
    Name = "bastion-host-rt-WC"
  }

}


resource "aws_route_table_association" "rt-subnet1-public" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.public_rt.id

}

resource "aws_route_table_association" "rt-subnet2-public" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.public_rt.id

}



resource "aws_db_subnet_group" "private-subnet-group" {
  name       = "private-subnet-group"
  subnet_ids = [aws_subnet.private-subnet1.id, aws_subnet.private-subnet2.id]

  tags = {
    Name = "default-group-WC"
  }

}
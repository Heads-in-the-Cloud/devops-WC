
data "aws_availability_zones" "available" {
  state = "available"
}


data "aws_vpc" "vpc_peering" {
    provider = aws.home
    filter {
      name   = "tag:Name"
      values = [ var.peering_vpc_name ]
    }
}

data "aws_route_table" "peering_vpc_rt" {
    provider = aws.home
    filter {
      name   = "tag:Name"
      values = [ var.peering_rt_name ]
    }
}

data "aws_secretsmanager_secret" "secrets" {
  name                            = var.ssm_path
}


resource "aws_secretsmanager_secret_version" "secret_string" {
  secret_id     = data.aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode(merge({"private_subnet_group_id" = aws_db_subnet_group.private-subnet-group.id},
                                   {"vpc_id"                  = aws_vpc.my_vpc.id},
                                   {"public_subnet_id"        = aws_subnet.public_1.id}))
}

resource "aws_vpc" "my_vpc" {
  cidr_block            = var.vpc_cidr_block
  enable_dns_hostnames  = true
  tags = {
    Name = "${var.vpc_name}-${var.environment}"
  }
}

resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet1_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "wc_private_subnet_1-${var.environment}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet2_cidr_block
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "wc_private_subnet_2-${var.environment}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}



resource "aws_subnet" "public_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet3_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "wc_public_subnet_1-${var.environment}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.subnet4_cidr_block
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "wc_public_subnet_2-${var.environment}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}



resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "${var.internet_gw_name}"
  }
}

resource "aws_vpc_peering_connection" "pc" {
  peer_owner_id = var.aws_account_id
  peer_vpc_id   = data.aws_vpc.vpc_peering.id
  peer_region   = var.aws_home_region
  vpc_id        = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.pc_name}"
  }
}

resource "aws_vpc_peering_connection_accepter" "peer" {
  provider                  = aws.home
  vpc_peering_connection_id = aws_vpc_peering_connection.pc.id
  auto_accept               = true

  tags = {
    Side = "Accepter"
  }
}

resource "aws_route" "peering_vpc_route" {
  provider = aws.home
  route_table_id            = data.aws_route_table.peering_vpc_rt.id
  destination_cidr_block    = aws_vpc.my_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.pc.id

}

resource "aws_eip" "nat" {
  vpc        = true
  depends_on = [aws_internet_gateway.default]
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id
  depends_on    = [aws_internet_gateway.default]

  tags = {
    Name        = "wc_nat"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = var.anywhere_ipv4
  nat_gateway_id         = aws_nat_gateway.nat.id
}


resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.anywhere_ipv4
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "wc_public_rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block                = data.aws_vpc.vpc_peering.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.pc.id
  }

  tags = {
    Name = "wc_private_rt"
  }
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}


resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}


resource "aws_db_subnet_group" "private-subnet-group" {
  name       = "wc_private_subnet_group_${var.environment}"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "wc_default_db_sg_${var.environment}"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "private_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet1_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "wc_private_subnet_1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet2_cidr_block
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "wc_private_subnet_2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb" = 1
  }
}

# resource "aws_subnet" "private_3" {
#   vpc_id            = var.vpc_id
#   cidr_block        = var.subnet3_cidr_block
#   availability_zone = data.aws_availability_zones.available.names[2]

#   tags = {
#     Name = "wc_private_subnet_3"
#     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
#     "kubernetes.io/role/internal-elb" = 1
#   }
# }

resource "aws_subnet" "public_1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet4_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "wc_public_subnet_1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

resource "aws_subnet" "public_2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.subnet5_cidr_block
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "wc_public_subnet_2"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb" = 1
  }
}

# resource "aws_subnet" "public_3" {
#   vpc_id            = var.vpc_id
#   cidr_block        = var.subnet6_cidr_block
#   availability_zone = data.aws_availability_zones.available.names[2]
#   map_public_ip_on_launch = true

#   tags = {
#     Name = "wc_public_subnet_3"
#     "kubernetes.io/cluster/${var.cluster_name}" = "shared"
#     "kubernetes.io/role/elb" = 1
#   }
# }


resource "aws_internet_gateway" "default" {
  vpc_id = var.vpc_id

  tags = {
    Name = "wc_default_ig"
  }
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
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route" "route_default_vpc" {
  route_table_id            = "${var.default_rt_id}"
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.pc.id

}

resource "aws_route" "route_wc_vpc" {
  route_table_id            = aws_route_table.private.id
  destination_cidr_block    = var.rt_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.pc.id

}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = var.public_cidr_block
    gateway_id = aws_internet_gateway.default.id
  }

  tags = {
    Name = "wc_public_rt"
  }
}

resource "aws_route_table" "private" {
  vpc_id = var.vpc_id

  route = []

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

# resource "aws_route_table_association" "public_3" {
#   subnet_id      = aws_subnet.public_3.id
#   route_table_id = aws_route_table.public.id
# }

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}

# resource "aws_route_table_association" "private_3" {
#   subnet_id      = aws_subnet.private_3.id
#   route_table_id = aws_route_table.private.id
# }

resource "aws_db_subnet_group" "private-subnet-group" {
  name       = "wc_private_subnet_group"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "wc_default_db_sg"
  }
}

resource "aws_vpc_peering_connection" "pc" {
  peer_owner_id = var.peer_owner_id
  peer_vpc_id   = var.vpc_id
  vpc_id        = var.peer_vpc_id
  auto_accept   = true
  tags = {
    Name = "wc-pc-Jenkins"
  }

}
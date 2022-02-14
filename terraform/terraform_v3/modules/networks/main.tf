
resource "aws_eip" "nat" {
  vpc        = true
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = var.public_subnet_1

  tags = {
    Name        = "Jenkins_nat"
  }
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = var.rt_id
  destination_cidr_block = var.public_cidr_block
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_db_subnet_group" "private-subnet-group" {
  name       = "wc_private_subnet_group"
  subnet_ids = [var.private_subnet_1, var.private_subnet_2]

  tags = {
    Name = "wc_default_db_sg"
  }
}

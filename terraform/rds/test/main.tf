data "aws_ami" "amazon_linux" {
  most_recent      = true
  owners           = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-kernel*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "test-vpc-wc"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "default" {
  vpc_id = aws_vpc.vpc.id
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.default.id
  }
}

resource "aws_instance" "bastion_host" {
  ami                       = data.aws_ami.amazon_linux.id
  availability_zone         = data.aws_availability_zones.available.names[0]
  instance_type             = var.instance_type
  key_name                  = var.key_pair_name
  vpc_security_group_ids    = [ aws_security_group.ssh_sg.id ]
  subnet_id                 = aws_subnet.test_subnet.id
  user_data                 = templatefile("${path.root}/test_mysql_connection.sh", {
    RDS_MYSQL_ENDPOINT      = var.db_host
    RDS_MYSQL_USER          = var.db_user
    RDS_MYSQL_PASS          = var.db_password
    RDS_MYSQL_BASE          = "utopia"
  })
  tags = {
    Name                    = "test-ssh-instance"
  }
}

resource "aws_security_group" "ssh_sg" {
  name        = "wc-terratest-ssh-sg"
  description = "ssh_sh"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "allow ssh"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
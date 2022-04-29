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


resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "test-vpc-wc"
  }
}

resource "aws_subnet" "test_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.10.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_instance" "bastion_host" {
  ami                       = data.aws_ami.amazon_linux.id
  instance_type             = var.instance_type
  key_name                  = var.key_pair_name
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
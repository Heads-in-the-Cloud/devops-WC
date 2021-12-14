
resource "aws_instance" "bastion_host" {
  ami                       = var.ami_id
  instance_type             = var.instance_type
  key_name                  = var.key_name
  vpc_security_group_ids    = [ aws_security_group.ssh_sg.id ]
  subnet_id                 = var.public_subnet_id
  user_data                 = templatefile("${path.root}/mysql_starter_script.sh", {
    RDS_MYSQL_ENDPOINT      = aws_db_instance.rds.address
    RDS_MYSQL_USER          = var.db_username
    RDS_MYSQL_PASS          = var.db_password
    RDS_MYSQL_BASE          = "${var.db_name}"
  })
  tags = {
    Name                    = "bastion-host-WC"
  }
}


resource "aws_security_group" "ssh_sg" {
  name        = "ssh_sg_WC"
  description = "Allow all SSH from any IPv4"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ssh_sg"
  }
}

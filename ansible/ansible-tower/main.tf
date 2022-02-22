resource "aws_instance" "bastion_host" {
  ami                       = "ami-0b28dfc7adc325ef4"
  instance_type             = "db.t3.large"
  key_name                  = "GroupKey"
  vpc_security_group_ids    = [ aws_security_group.ssh_sg.id ]
  subnet_id                 = "subnet-011ddfcbc5d63bdf8"
  user_data                 = templatefile("${path.root}ansible-tower/ansible-tower-setup.sh")
  tags = {
    Name                    = "Ansible-Tower"
  }
}


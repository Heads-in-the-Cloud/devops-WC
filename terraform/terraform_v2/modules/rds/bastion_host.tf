
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

resource "aws_instance" "bastion_host" {
  ami                       = aws_ami.amazon_linux.id
  instance_type             = var.instance_type
  key_name                  = var.key_name
  vpc_security_group_ids    = [ aws_security_group.ssh_sg.id ]
  subnet_id                 = var.public_subnet_id
  iam_instance_profile      = aws_iam_instance_profile.bastion_host_profile.name
  user_data                 = templatefile("${path.root}/mysql_starter_script.sh", {
    RDS_MYSQL_ENDPOINT      = aws_db_instance.rds.address
    RDS_MYSQL_USER          = var.db_user
    RDS_MYSQL_PASS          = random_password.db_password.result
    RDS_MYSQL_BASE          = "${var.db_name}"
  })
  tags = {
    Name                    = "bastion-host-WC_${var.environment}"
  }
}

resource "aws_security_group_rule" "ec2_ingress_rules" {
  count = length(var.ec2_ingress)

  type              = "ingress"
  from_port         = var.ec2_ingress[count.index].from_port
  to_port           = var.ec2_ingress[count.index].to_port
  protocol          = var.ec2_ingress[count.index].protocol
  cidr_blocks       = var.ec2_ingress[count.index].cidr_blocks
  description       = var.ec2_ingress[count.index].description
  security_group_id = aws_security_group.ec2_sg.id

}

resource "aws_security_group_rule" "ec2_egress_rules" {
  count = length(var.ec2_egress)

  type              = "egress"
  from_port         = var.ec2_egress[count.index].from_port
  to_port           = var.ec2_egress[count.index].to_port
  protocol          = var.ec2_egress[count.index].protocol
  cidr_blocks       = var.ec2_egress[count.index].cidr_blocks
  ipv6_cidr_blocks  = var.ec2_egress[count.index].ipv6_cidr_blocks
  description       = var.ec2_egress[count.index].description
  security_group_id = aws_security_group.ec2_sg.id

}


resource "aws_security_group" "ec2_sg" {
  name        = "ssh_sg_WC"
  description = "Allow all SSH from any IPv4"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ssh_sg_${var.environment}"
  }
}

resource "aws_iam_instance_profile" "bastion_host_profile" {
  name = "bastion_host_profile_WC_${var.environment}"
  role = aws_iam_role.s3_iam_role.name
}


resource "aws_iam_role" "s3_iam_role" {
  name               = "S3BucketReadOnly"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


data "aws_iam_policy" "s3_read_only" {
  arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "s3_policy_attachment" {
  role       = aws_iam_role.s3_iam_role.name
  policy_arn = data.aws_iam_policy.s3_read_only.arn
}


resource "aws_instance" "bastion_host" {
  ami                       = var.ami_id
  instance_type             = var.instance_type
  key_name                  = var.key_name
  vpc_security_group_ids    = [ aws_security_group.ssh_sg.id ]
  subnet_id                 = var.public_subnet_id
  iam_instance_profile      = aws_iam_instance_profile.bastion_host_profile.name
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

resource "aws_iam_instance_profile" "bastion_host_profile" {
  name = "bastion_host_profile_WC"
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




data "aws_secretsmanager_secret" "secrets" {
  name                            = var.ssm_path
}


variable "rds_ingress" {
    type = list(object({
        description     = string
        from_port       = number        
        to_port         = number
        protocol        = string
        cidr_blocks     = list(string)
        ipv6_cidr_blocks= list(string)
    }))
    default = [
                          {
                            description      = "Allow HTTP from any IPv4",
                            from_port        = 80,
                            to_port          = 80,
                            protocol         = "tcp",
                            cidr_blocks      = ["0.0.0.0/0"],
                          },
                          {
                            description      = "Allow connection to MYSQL",
                            from_port        = "${var.db_driver == "mysql" ? 3306 : var.db_driver == "postgres" ? 5432 : ""}",
                            to_port          = "${var.db_driver == "mysql" ? 3306 : var.db_driver == "postgres" ? 5432 : ""}",
                            protocol         = "tcp",
                            cidr_blocks      = ["0.0.0.0/0"],           
                          }
                          ]
  rds_egress            = [{
                            description      = "Allow egress to anywhere ipv4/ipv6",
                            from_port        = 0,
                            to_port          = 0,
                            protocol         = "-1",
                            cidr_blocks      = ["0.0.0.0/0"],
                            ipv6_cidr_blocks = ["::/0"]
                          }]
  ec2_ingress           = [{
                            description      = "Allow SSH from anywhere",
                            from_port        = 22,
                            to_port          = 22,
                            protocol         = "tcp",
                            cidr_blocks      = ["0.0.0.0/0"], 
                          }]
  ec2_egress            = [{
                          description      = "Allow egress to anywhere ipv4/ipv6",
                          from_port        = 0,
                          to_port          = 0,
                          protocol         = "-1",
                          cidr_blocks      = ["0.0.0.0/0"],
                          ipv6_cidr_blocks = ["::/0"]
                          }]
}


locals {
  secrets = jsondecode(
    data.aws_secretsmanager_secret_version.secrets.secret_string
  )
  # database_ingress_port = var.db_driver == "${"mysql" ? 3306: var.db_driver == "postgres" ? 5432 : ""}"
}


#local.secrets.subnet_id_1
resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}


resource "random_password" "secret_key" {
  length           = 16
  special          = false
}

resource "aws_secretsmanager_secret_version" "secret_string" {
  secret_id     = data.aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode(merge({"db_password" = random_password.db_password.result},
                                   {"db_host"     = aws_db_instance.rds.address},
                                   {"secret_key"  = random_password.secret_key.result},
                                   {"db_user"     = var.db_user}))
}

resource "aws_db_instance" "rds" {
  allocated_storage    = 10
  engine               = var.db_engine
  engine_version       = var.db_engine_version
  instance_class       = var.db_instance
  name                 = var.db_name
  username             = var.db_user
  password             = random_password.db_password.result
  skip_final_snapshot  = true
  identifier           = var.db_identifier
  db_subnet_group_name = local.secrets.private_subnet_group_id
  vpc_security_group_ids = [ aws_security_group.db_sg.id ]

}

resource "aws_security_group_rule" "ingress_rules" {
  count = length(var.rds_ingress)

  type              = "ingress"
  from_port         = var.rds_ingress[count.index].from_port
  to_port           = var.rds_ingress[count.index].to_port
  protocol          = var.rds_ingress[count.index].protocol
  cidr_blocks       = var.rds_ingress[count.index].cidr_blocks
  description       = var.rds_ingress[count.index].description
  security_group_id = aws_security_group.db_sg.id

}

resource "aws_security_group_rule" "egress_rules" {
  count = length(var.rds_egress)

  type              = "egress"
  from_port         = var.rds_egress[count.index].from_port
  to_port           = var.rds_egress[count.index].to_port
  protocol          = var.rds_egress[count.index].protocol
  cidr_blocks       = var.rds_egress[count.index].cidr_blocks
  ipv6_cidr_blocks  = var.rds_egress[count.index].ipv6_cidr_blocks
  description       = var.rds_egress[count.index].description
  security_group_id = aws_security_group.db_sg.id

}

resource "aws_security_group" "db_sg" {
  name        = "db_sg_WC_${var.environment}"
  description = "Security group for rds instance"
  vpc_id      = local.secrets.vpc_id

  tags = {
    Name = "db_sg_WC_${var.environment}"
  }

}

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
  ami                       = data.aws_ami.amazon_linux.id
  instance_type             = var.instance_type
  key_name                  = var.key_name
  vpc_security_group_ids    = [ aws_security_group.ec2_sg.id ]
  subnet_id                 = local.secret.public_subnet_id
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
  vpc_id      = local.secrets.vpc_id

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

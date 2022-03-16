
data "aws_secretsmanager_secret" "secrets" {
  name                            = var.ssm_path
}

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
  db_subnet_group_name = var.subnet_group_id
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

  # ingress {
  #   description      = "Allow HTTP from any IPv4"
  #   from_port        = 80
  #   to_port          = 80
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]

  # }

  # ingress {
  #   description      = "Allow connection to MYSQL"
  #   from_port        = var.mysql_port
  #   to_port          = var.mysql_port
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  # }

  # egress {
  #   from_port        = 0
  #   to_port          = 0
  #   protocol         = "-1"
  #   cidr_blocks      = ["0.0.0.0/0"]
  #   ipv6_cidr_blocks = ["::/0"]
  # }

  tags = {
    Name = "db_sg_WC_${var.environment}"
  }

}
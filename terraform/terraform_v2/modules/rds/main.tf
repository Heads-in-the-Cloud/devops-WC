
resource "aws_secretsmanager_secret" "secrets" {
  name                            = var.ssm_path
  force_overwrite_replica_secret  = true
}

resource "aws_secretsmanager_secret_version" "secret_string" {
  secret_id     = aws_secretsmanager_secret.secrets.id
  secret_string = jsonencode(var.secrets_data)
}

# resource "aws_db_instance" "rds" {
#   allocated_storage    = 10
#   engine               = var.db_engine
#   engine_version       = var.db_engine_version
#   instance_class       = var.db_instance
#   name                 = var.db_name
#   username             = var.db_username
#   password             = var.secrets_data["db_password"]
#   skip_final_snapshot  = true
#   identifier           = var.db_identifier
#   db_subnet_group_name = var.subnet_group_id
#   vpc_security_group_ids = [ aws_security_group.db_sg.id ]

# }



# resource "aws_security_group" "db_sg" {
#   name        = "db_sg_WC_${var.environment}"
#   description = "Allow HTTP from any IPv4"
#   vpc_id      = var.vpc_id

#   ingress {
#     description      = "Allow HTTP from any IPv4"
#     from_port        = 80
#     to_port          = 80
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]

#   }

#   ingress {
#     description      = "Allow connection to MYSQL"
#     from_port        = var.mysql_port
#     to_port          = var.mysql_port
#     protocol         = "tcp"
#     cidr_blocks      = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port        = 0
#     to_port          = 0
#     protocol         = "-1"
#     cidr_blocks      = ["0.0.0.0/0"]
#     ipv6_cidr_blocks = ["::/0"]
#   }

#   tags = {
#     Name = "db_sg_WC_${var.environment}"
#   }

# }
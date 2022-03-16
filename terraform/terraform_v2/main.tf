

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

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = var.ssm_path
}

data "aws_ecr_repository" "user-container" {
    name = var.users_repo
}

data "aws_ecr_repository" "flight-container" {
    name = var.flights_repo
}

data "aws_ecr_repository" "booking-container" {
    name = var.bookings_repo
}

data "aws_ecr_repository" "frontend-container" {
    name = var.frontend_repo
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.secrets.secret_string
  )
}

module "networks" {

  source                = "./modules/networks"
  vpc_cidr_block        = "10.10.0.0/16"
  subnet1_cidr_block    = "10.10.1.0/24"
  subnet2_cidr_block    = "10.10.2.0/24"
  subnet3_cidr_block    = "10.10.3.0/24"
  subnet4_cidr_block    = "10.10.4.0/24"
  anywhere_ipv4         = "0.0.0.0/0"
  vpc_name              = "WC-vpc"
  internet_gw_name      = "WC-ig"
  region                = var.region
  environment           = var.environment
  cluster_name          = var.cluster_name #tag identifier for ALB ingress controller
}

module "rds" {

  source                = "./modules/rds"
  db_instance           = "db.t2.micro"
  db_identifier         = "database-wc"
  db_name               = "utopia"
  db_engine             = "mysql"
  db_engine_version     = "8.0"
  instance_type         = "t2.micro"
  key_name              = var.key_name
  environment           = var.environment
  secrets_data          = { "db_user" = "wc_db_user",
                            "db_password" = random_password.password.result,
                            "secret_key" = var.secret_key }
  rds_ingress           = [
                          {
                            description      = "Allow HTTP from any IPv4"
                            from_port        = 80
                            to_port          = 80
                            protocol         = "tcp"
                            cidr_blocks      = ["0.0.0.0/0"]
                          },
                          {
                            description      = "Allow connection to MYSQL"
                            from_port        = var.mysql_port
                            to_port          = var.mysql_port
                            protocol         = "tcp"
                            cidr_blocks      = ["0.0.0.0/0"]           
                          }
                          ]
  rds_egress            = [{
                            description      = "Allow egress to anywhere ipv4/ipv6"
                            from_port        = 0
                            to_port          = 0
                            protocol         = "-1"
                            cidr_blocks      = ["0.0.0.0/0"]
                            ipv6_cidr_blocks = ["::/0"]
                          }]
  ssm_path              = var.ssm_path
  ami_id                = data.aws_ami.amazon_linux.id
  subnet_group_id       = module.networks.subnet_group_id
  public_subnet_id      = element(module.networks.public-subnet-ids, 0)
  vpc_id                = module.networks.vpc.id

  ssh_port              = "22"
  http_port             = "80"
  https_port            = "443"
  mysql_port            = "3306"
}
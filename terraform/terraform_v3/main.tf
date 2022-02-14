data "aws_vpc" "jenkins_vpc" {
    filter {
      name   = "tag:Name"
      values = ["Jenkins-VPC"]
    }
}

data "aws_subnet" "jenkins_public_1" {
    tags = {
      "Name" = "Jenkins-Public-1-c"
      }
}
data "aws_subnet" "jenkins_public_2" {
    tags = {
      "Name" = "Jenkins-Public-2"
      }
}
data "aws_subnet" "jenkins_private_1" {
    tags = {
      "Name" = "Jenkins-Private-1"
      }
}
data "aws_subnet" "jenkins_private_2" {
    tags = {
      "Name" = "Jenkins-Private-2"
      }
}

data "aws_route_table" "private_rt" {
  subnet_id = data.aws_subnet.jenkins_private_1.id
}


data "aws_secretsmanager_secret_version" "secrets" {
  secret_id = "prod/Walter/secrets"
}

data "aws_ecr_repository" "user-container" {
    name = "wc-users-api"
}

data "aws_ecr_repository" "flight-container" {
    name = "wc-flights-api"
}

data "aws_ecr_repository" "booking-container" {
    name = "wc-bookings-api"
}

data "aws_ecr_repository" "frontend-container" {
    name = "wc-frontend"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.secrets.secret_string
  )
}

module "networks" {
  source                = "./modules/networks"
  public_cidr_block     = "0.0.0.0/0"
  vpc_id                = data.aws_vpc.jenkins_vpc.id
  region                = "us-west-2"
  cluster_name          = "UtopiaClusterWC"
  public_subnet_1       = data.aws_subnet.jenkins_public_1.id
  public_subnet_2       = data.aws_subnet.jenkins_public_2.id
  private_subnet_1      = data.aws_subnet.jenkins_private_1.id
  private_subnet_2      = data.aws_subnet.jenkins_private_2.id
  rt_id                 = data.aws_route_table.private_rt.id
}

module "rds" {
  source                = "./modules/rds"
  db_instance           = "db.t2.micro"
  db_identifier         = "database-wc-${var.environment}"
  db_name               = "utopia-${var.environment}"
  db_engine             = "mysql"
  db_engine_version     = "8.0"
  ami_id                = "ami-00f7e5c52c0f43726"
  subnet_group_id       = module.networks.subnet_group_id
  public_subnet_id      = data.aws_subnet.jenkins_public_1.id
  vpc_id                = data.aws_subnet.jenkins_vpc.id
  db_username           = local.db_creds.db_username
  db_password           = local.db_creds.db_password
  environment           = var.environment
}
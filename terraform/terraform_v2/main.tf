

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
  # providers = {
  #     aws = aws.us_west_1
  # }
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

# module "rds" {
#   providers = {
#       aws = aws.us-west-2
#   }
#   source                = "./modules/rds"
#   db_instance           = "db.t2.micro"
#   db_identifier         = "database-wc"
#   db_name               = "utopia"
#   db_engine             = "mysql"
#   db_engine_version     = "8.0"
#   ami_id                = "ami-00f7e5c52c0f43726"
#   subnet_group_id       = module.networks.subnet_group_id
#   public_subnet_id      = element(module.networks.public-subnet-ids, 0)
#   vpc_id                = module.networks.vpc.id
#   db_username           = local.db_creds.db_username
#   db_password           = local.db_creds.db_password
#   ssh_port              = "22"
#   http_port             = "80"
#   https_port            = "443"
# }
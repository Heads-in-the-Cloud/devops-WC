
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
  vpc_cidr_block        = "10.10.0.0/16"
  subnet1_cidr_block    = "10.10.1.0/24"
  subnet2_cidr_block    = "10.10.2.0/24"
  subnet3_cidr_block    = "10.10.3.0/24"
  subnet4_cidr_block    = "10.10.4.0/24"
  rt_cidr_block         = "0.0.0.0/0"
  vpc_name              = "WC-vpc"
  internet_gw_name      = "bastion-host-ig-WC"
  region                = "us-west-2"
  default_rt_id         = "rtb-048596a1592577216"

}

module "rds" {
  source                = "./modules/rds"
  db_instance           = "db.t2.micro"
  db_identifier         = "database-wc"
  db_name               = "utopia"
  db_engine             = "mysql"
  db_engine_version     = "8.0"
  subnet_group_id       = module.networks.subnet_group_id
  public_subnet_id      = element(module.networks.public-subnet-ids, 0)
  vpc_id                = module.networks.vpc.id
  db_username           = local.db_creds.db_username
  db_password           = local.db_creds.db_password
}
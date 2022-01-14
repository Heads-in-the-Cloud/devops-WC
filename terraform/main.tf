
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

data "aws_vpc" "default_vpc" {
    id = "${var.default_vpc_id}"
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
  peer_owner_id         = "026390315914"
  vpc_name              = "WC-vpc"
  internet-gw-name      = "bastion-host-ig-WC"
  pc_name               = "wc-pc-01"
  region                = "us-west-2"
  default_rt_id         = "rtb-048596a1592577216"
  peer_vpc_id           = data.aws_vpc.default_vpc.id
  default_vpc_cidr      = data.aws_vpc.default_vpc.cidr_block

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
  vpc_id                = module.networks.db-vpc.id
  db_username           = local.db_creds.db_username
  db_password           = local.db_creds.db_password
  alb_sg_id             = module.load_balancer.alb_sg_id
}

module "cluster" {
    source              = "./modules/cluster"
    app_port            = 5000
    public_subnet_ids   = module.networks.public-subnet-ids
    user_tg_id          = module.load_balancer.target_groups["user-tg"].id
    flight_tg_id        = module.load_balancer.target_groups["flight-tg"].id
    booking_tg_id       = module.load_balancer.target_groups["booking-tg"].id
    alb_sg_id           = module.load_balancer.alb_sg_id
    booking_rule        = module.load_balancer.booking_rule
    flight_rule         = module.load_balancer.flight_rule    
    vpc_id              = module.networks.db-vpc.id
    environment         = [
        {"name": "DB_HOST", "value": module.rds.db_instance.address},
        {"name": "USERS_PORT", "value": 5000},
        {"name": "FLIGHTS_PORT", "value": 5000},
        {"name": "BOOKINGS_PORT", "value": 5000},
        {"name": "FRONTEND_PORT", "value": 5000},
        {"name": "HOST_DOMAIN", "value": "http://${module.load_balancer.alb_dns}"}
    ]
    task_definitions = {
      "${var.user_task}" = {
        cpu = "1vCPU"
        family = "users-task-WC"
        memory = "2GB"
        image = "${data.aws_ecr_repository.user-container.repository_url}:latest"
        network_mode = "awsvpc"
        container_name = var.user_container_name
        container_secrets = var.container_secrets
      },
      "${var.flight_task}" = {
      cpu = "1vCPU"
      family = "flights-task-WC"
      memory = "2GB"
      image = "${data.aws_ecr_repository.flight-container.repository_url}:latest"
      network_mode = "awsvpc"
      container_name = var.flight_container_name
      container_secrets = var.container_secrets

      },
      "${var.booking_task}" = {
        cpu = "1vCPU"
        family = "bookings-task-WC"
        memory = "2GB"
        image = "${data.aws_ecr_repository.booking-container.repository_url}:latest"
        network_mode = "awsvpc"
        container_name = var.booking_container_name
        container_secrets = var.container_secrets

      },     
      "${var.frontend_task}" = {
        cpu = "1vCPU"
        family = "frontend-task-WC"
        memory = "2GB"
        image = "${data.aws_ecr_repository.frontend-container.repository_url}:latest"
        network_mode = "awsvpc"
        container_name = var.frontend_container_name
        container_secrets = var.container_secrets

      }  
    }
    ecs_services = {
      "users-service" = {
        container_name = var.user_container_name
        desired_count = 2
        name = "user-service-WC"
        target_group_arn = module.load_balancer.target_groups["user-tg"].id
        task_name        = var.user_task
      }
      "flights-service" = {
        container_name = var.flight_container_name
        desired_count = 2
        name = "flight-service-WC"
        target_group_arn = module.load_balancer.target_groups["flight-tg"].id
        task_name        = var.flight_task

      }
      "bookings-service" = {
        container_name = var.booking_container_name
        desired_count = 2
        name = "booking-service-WC"
        target_group_arn = module.load_balancer.target_groups["booking-tg"].id
        task_name        = var.booking_task

      }
      "frontend-service" = {
        container_name = var.frontend_container_name
        desired_count = 2
        name = "frontend-service-WC"
        target_group_arn = module.load_balancer.target_groups["frontend-tg"].id
        task_name        = var.frontend_task

      }
    }
}

module "load_balancer" {
    source               = "./modules/load_balancer"
    vpc_id               = module.networks.db-vpc.id
    app_port             = 5000
    hosted_zone          = "hitwc.link"
    public_subnet_ids    = module.networks.public-subnet-ids
    target_groups = {
      "user-tg" = {
        healthy_threshold = "3"
        interval = "30"
        matcher = "200"
        name = "user-tg-WC"
        protocol = "HTTP"
        target_type = "ip"
        timeout = "3"
        unhealthy_threshold = "2"
        health = "/health"
      }
      "flight-tg" = {
        healthy_threshold = "3"
        interval = "30"
        matcher = "200"
        name = "flight-tg-WC"
        protocol = "HTTP"
        target_type = "ip"
        timeout = "3"
        unhealthy_threshold = "2"
        health = "/airline/read/airport"
      }
      "booking-tg" = {
        healthy_threshold = "3"
        interval = "30"
        matcher = "200"
        name = "booking-tg-WC"
        protocol = "HTTP"
        target_type = "ip"
        timeout = "3"
        unhealthy_threshold = "2"
        health = "/health"
      }
      "frontend-tg" = {
        healthy_threshold = "3"
        interval = "30"
        matcher = "200"
        name = "frontend-tg-WC"
        protocol = "HTTP"
        target_type = "ip"
        timeout = "3"
        unhealthy_threshold = "2"
        health = "/health"
      }
    }
}  

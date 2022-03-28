variable "db_instance" {
    type=string
    default="db.t2.micro"
}

variable "db_identifier" {
    type=string
    default="database-wc"
}

variable "db_name" {
    type=string
    default="utopia"
}

variable "db_engine" {
    type=string
    default="mysql"
}

variable "db_engine_version" {
    type=string
    default="8.0"
}

variable "instance_type" {
    type=string
    default="t2.micro"
}

variable "db_user" {
    type=string
    default="wc_db_admin"
}

variable "key_name" {
    type=string
}

variable "environment" {
    type=string
}

variable "ssm_path" { 
    type=string 
}

locals {
  database_ingress_port = var.db_driver == "${"mysql" ? 3306: var.db_driver == "postgres" ? 5432 : ""}"
}



#   subnet_group_id       = module.networks.subnet_group_id
#   public_subnet_id      = element(module.networks.public-subnet-ids, 0)
#   vpc_id                = module.networks.vpc.id
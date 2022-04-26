variable "vpc_cidr_block" { type = string } 

variable "region" { type = string }

variable "environment" { type = string }

variable "subnet1_cidr_block" { type = string }

variable "subnet2_cidr_block" { type = string }

variable "subnet3_cidr_block" { type = string }

variable "subnet4_cidr_block" { type = string }

variable "anywhere_ipv4" { type = string }

variable "vpc_name" { type = string }

variable "internet_gw_name" { type = string }

variable "cluster_name" { type = string }

variable "peering_vpc_name" { type = string }

variable "peering_rt_name" { type = string }

variable "pc_name" { type = string }

variable "aws_account_id" { type = string }

variable "ssm_path" { type=string }

variable "secrets_key_subnet_group_id" { type=string }

variable "secrets_key_vpc_id" { type=string }

variable "secrets_key_public_subnet_id" { type=string }

variable "aws_home_region" { 
    type=string
    default = "us-west-2"
}
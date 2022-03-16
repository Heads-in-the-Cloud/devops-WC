variable "environment" { type=string }

variable "ssm_path" { type=string }

variable "db_instance"{ type=string }

variable "db_name"{ type=string }

variable "db_identifier"{ type=string }

variable "db_engine_version"{ type=string }

variable "db_engine"{ type=string }

variable "subnet_group_id"{ type=string }

variable "vpc_id"{ type=string }

variable "db_username"{ type=string }

variable "ami_id" { type=string }

variable "instance_type" { type=string }

variable "key_name" { type=string }

variable "public_subnet_id" { type=string }

variable "ssh_port" { type=number }

variable "http_port" { type=number }

variable "https_port" { type=number }

variable "mysql_port" { type=number }

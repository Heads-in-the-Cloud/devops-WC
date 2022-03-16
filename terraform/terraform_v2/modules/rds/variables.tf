variable "environment" { type=string }

variable "secrets_data" { type = map(string) }

variable "ssm_path" { type=string }

variable "db_instance"{ type=string }

variable "db_name"{ type=string }

variable "db_identifier"{ type=string }

variable "db_engine_version"{ type=string }

variable "db_engine"{ type=string }

variable "subnet_group_id"{ type=string }

variable "vpc_id"{ type=string }

variable "ami_id" { type=string }

variable "instance_type" { type=string }

variable "key_name" { type=string }

variable "public_subnet_id" { type=string }

variable "ssh_port" { type=number }

variable "http_port" { type=number }

variable "https_port" { type=number }

variable "mysql_port" { type=number }

variable "rds_ingress" { 
    type = map(object({
        description     = string
        from_port       = number        
        to_port         = number
        protocol        = string
        cidr_blocks     = list(string)
    }))
}

# variable "rds_egress" { 
#     type = list(map(object({
#         description     = string
#         from_port       = number        
#         to_port         = number
#         protocol        = string
#         cidr_blocks     = list(string)
#         ipv6_cidr_blocks= list(string)
#     })))
# }
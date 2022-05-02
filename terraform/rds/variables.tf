variable "region" {
  type=string
}
variable "db_instance" {
    type=string
    default="db.t2.micro"
}

variable "list_of_secrets"{
  type = list(string)
  default = ["db_password", "secret_key", "db_user"]
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

variable "key_name_test"{
    type=string
}

variable "environment" {
    type=string
}

variable "ssm_path" { 
    type=string 
}

variable "secrets_key_password" {
    type=string
}

variable "secrets_key_host" {
    type=string
}

variable "secrets_key_user" {
    type=string
}

variable "secrets_key_jwt_key" {
    type=string
}

variable "ecs_log_prefix" {
    type=string
}

variable "eks_log_prefix" {
    type=string
}

variable "rds_ingress" {
    type = list(object({
        description     = string
        from_port       = number        
        to_port         = number
        protocol        = string
        cidr_blocks     = list(string)
    }))
    default = [
          {
            description      = "Allow HTTP from any IPv4",
            from_port        = 80,
            to_port          = 80,
            protocol         = "tcp",
            cidr_blocks      = ["0.0.0.0/0"],
          },
          {
            description      = "Allow connection to MYSQL",
            from_port        = 3306,
            to_port          = 3306,
            protocol         = "tcp",
            cidr_blocks      = ["0.0.0.0/0"],           
          }]
  }
  variable "rds_egress" {
    type = list(object({
        description     = string
        from_port       = number        
        to_port         = number
        protocol        = string
        cidr_blocks     = list(string)
        ipv6_cidr_blocks= list(string)
    }))
    default = [
      {
        description      = "Allow egress to anywhere ipv4/ipv6",
        from_port        = 0,
        to_port          = 0,
        protocol         = "-1",
        cidr_blocks      = ["0.0.0.0/0"],
        ipv6_cidr_blocks = ["::/0"]
      }]
  }

  variable "ec2_ingress"{
    type = list(object({
        description     = string
        from_port       = number        
        to_port         = number
        protocol        = string
        cidr_blocks     = list(string)
    }))

    default = [
      {
        description      = "Allow SSH from anywhere",
        from_port        = 22,
        to_port          = 22,
        protocol         = "tcp",
        cidr_blocks      = ["0.0.0.0/0"], 
      }]
  }
  variable "ec2_egress" {
    type = list(object({
        description     = string
        from_port       = number        
        to_port         = number
        protocol        = string
        cidr_blocks     = list(string)
        ipv6_cidr_blocks= list(string)
    }))
    default = [
      {
        description      = "Allow egress to anywhere ipv4/ipv6",
        from_port        = 0,
        to_port          = 0,
        protocol         = "-1",
        cidr_blocks      = ["0.0.0.0/0"],
        ipv6_cidr_blocks = ["::/0"]
      }]
}

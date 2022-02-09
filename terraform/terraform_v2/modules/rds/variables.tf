variable "db_instance"{
    type = string
    default = ""
}

variable "db_name"{
    type = string
    default = ""
}

variable "db_identifier"{
    type = string
    default = ""
}

variable "db_engine_version"{
    type = string
    default = ""
}

variable "db_engine"{
    type = string
    default = ""
}


variable "subnet_group_id"{
    type = string
    default = ""
}

variable "vpc_id"{
    type = string
    default = ""
}

variable "db_username"{
    type = string
    default = ""
}

variable "db_password"{
    type = string
    default = ""
}

variable "ami_id" {
    type = string
    default = ""
}

variable "instance_type" {
    type = string
    default = "t2.micro"
}


variable "key_name" {
    type = string
    default = "SSH_KEY_WC"
}

variable "public_subnet_id" {
    type = string
    default = ""
}

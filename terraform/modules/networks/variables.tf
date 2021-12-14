variable "subnets" {
    type = map(object({
        cidr_block = string
        tag_name = string
    }))
    description = "Subnets for the VPC"
    default = null
}

variable "vpc_cidr_block" {
    type = string
    default = ""
} 

variable "default_vpc_cidr" {
    type = string
    default = ""
}

variable "peer_vpc_id" {
    type = string
    default = ""
}

variable "peer_owner_id" {
    type = string
    default = ""
}

variable "pc_name" {
    type = string
    default = ""
}

variable "region" {
    type = string
    default = ""
}

variable "subnet1_cidr_block" {
    type = string
    default = ""
}

variable "subnet2_cidr_block" {
    type = string
    default = ""
}

variable "subnet3_cidr_block" {
    type = string
    default = ""
}

variable "subnet4_cidr_block" {
    type = string
    default = ""
}

variable "rt_cidr_block" {
    type = string
    default = ""
}

variable "default_rt_id" {
    type = string
    default = ""
}

variable "az_1" {
    type = string
    default = "us-west-2a"

}

variable "az_2" {
    type = string
    default = "us-west-2b"

}
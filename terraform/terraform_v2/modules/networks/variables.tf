variable "vpc_cidr_block" {
    type = string
    default = ""
} 

variable "vpc_id" {
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

variable "subnet5_cidr_block" {
    type = string
    default = ""
}

variable "subnet6_cidr_block" {
    type = string
    default = ""
}

variable "rt_cidr_block" {
    type = string
    default = ""
}

variable "public_cidr_block" {
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

variable "vpc_name" {
    type = string
    default = ""
}

variable "internet_gw_name" {
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

variable "cluster_name"{
    type = string
    default = ""
}
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

variable "az_1" {
    type = string
    default = "us-west-2a"

}

variable "az_2" {
    type = string
    default = "us-west-2b"

}
variable "app_port" {
  type = number
  default = 80
}

variable "user_container_uri" {
    type = string
    default = ""
}

variable "flight_container_uri" {
    type = string
    default = ""
}

variable "booking_container_uri" {
    type = string
    default = ""
}


variable "environment" {
    type = list
    default = []
}

variable "public_subnet_ids" {
    type = list
    default = []
}

variable "alb_sg_id" {
    type = string
    default = ""
}

variable "user_tg_id" {
    type = string
    default = ""
}

variable "flight_tg_id" {
    type = string
    default = ""
}
variable "booking_tg_id" {
    type = string
    default = ""
}

variable "vpc_id" {
    type = string
    default = ""
}

variable "task_definitions" {
    type = map(object({
        family = string
        network_mode = string        
        cpu = string
        memory = string
        image = string
        container_name = string
        container_secrets = list(any)
    }))
    description = "task definitions for containers"
    default = null
}

variable "ecs_services" {
    type = map(object({
        name = string
        target_group_arn = string        
        container_name = string
        desired_count = number
        task_name = string
    }))
    description = "services to run each task definition"
    default = null
}

variable "booking_rule" {
    type = any
    default = null
}

variable "flight_rule" {
    type = any
    default = null
}
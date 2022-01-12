variable "vpc_id" {
    type = string
    default = ""
}

variable "app_port" {
    type = number
    default = 80
}

variable "flights_path" {
    type = string
    default = "/airline/*"
}

variable "bookings_path" {
    type = string
    default = "/booking/*"
}

variable "frontend_path" {
    type = string
    default = "/lms/*"
}

variable "public_subnet_ids" {
    type = list
    default = []
}

variable "target_groups" {
    type = map(object({
        name = string
        protocol = string        
        target_type = string
        healthy_threshold = string
        matcher = string
        interval = string
        timeout = string
        unhealthy_threshold = string
        health = string
    }))
    description = "target groups for microservices"
    default = null
}

variable "user-tg" {
    type = string
    default = "user-tg"
}

variable "flight-tg" {
    type = string
    default = "flight-tg"
}

variable "booking-tg" {
    type = string
    default = "booking-tg"
}

variable "frontend-tg" {
    type = string
    default = "frontend-tg"
}

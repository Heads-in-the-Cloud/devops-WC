variable "user_task" {
    type = string
    default = "user-task"
    description = "name of users task definition"

}

variable "flight_task" {
    type = string
    default = "flight-task"
    description = "name of flights task definition"

}

variable "booking_task" {
    type = string
    default = "booking-task"
    description = "name of bookings task definition"

}

variable "user_container_name" {
    type = string
    default = "user-container-WC"
    description = "name of users container"

}

variable "flight_container_name" {
    type = string
    default = "flight-container-WC"
    description = "name of flights container"

}

variable "booking_container_name" {
    type = string
    default = "booking-container-WC"
    description = "name of bookings container"

}

variable "container_secrets" {
    type = list
    default = [
              {
        "name" : "DB_USER",
        "valueFrom" : "arn:aws:secretsmanager:us-west-2:026390315914:secret:prod/Walter/secrets-NSteFW:db_username::"
        },
        {
            "name" : "DB_USER_PASSWORD",
            "valueFrom" : "arn:aws:secretsmanager:us-west-2:026390315914:secret:prod/Walter/secrets-NSteFW:db_password::"
        },
        {
            "name" : "SECRET_KEY",
            "valueFrom" : "arn:aws:secretsmanager:us-west-2:026390315914:secret:prod/Walter/secrets-NSteFW:secret_key::"
        }
    ]
    description = "secrets from ssm to use in application"
}
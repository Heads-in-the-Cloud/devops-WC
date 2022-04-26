output "vpc_name"{
    value=aws_vpc.my_vpc
}

output "public_subnet1" {
    value=aws_subnet.public_1
}

output "public_subnet2" {
    value=aws_subnet.public_2
}

output "private_subnet1" {
    value=aws_subnet.private_1
}

output "private_subnet2" {
    value=aws_subnet.private_2
}

output "secret" {
    sensitive = true
    value=data.aws_secretsmanager_secret.secrets
}

output "secret_version" {
    sensitive = true
    value=aws_secretsmanager_secret_version.secret_string
}
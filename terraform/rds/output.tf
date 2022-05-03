output "bastion_host_instance" {
    value = aws_instance.bastion_host
    sensitive = true
}

output "secrets" {
    value = data.aws_secretsmanager_secret.secrets
    sensitive = true
}

output "random_password" {
    value = random_password.db_password
    sensitive = true
}

output "random_jwt_key" {
    value = random_password.secret_key
    sensitive = true
}

output "rds" {
    value = aws_db_instance.rds
    sensitive = true
}
output "bastion_host_instance" {
    value = aws_instance.bastion_host
    sensitive = true
}
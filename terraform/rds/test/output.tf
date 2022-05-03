output "vpc" {
    value = aws_vpc.vpc
}

output "instance" {
    value = aws_instance.bastion_host
}

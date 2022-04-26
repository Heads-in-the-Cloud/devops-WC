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
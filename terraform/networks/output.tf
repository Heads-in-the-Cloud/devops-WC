output "vpc_name"{
    value=aws_vpc.my_vpc
}

output "public_subnet1" {
    value=aws_subnet.public_1
}
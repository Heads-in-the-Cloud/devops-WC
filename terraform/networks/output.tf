output "vpc_name"{
    value=aws_vpc.my_vpc.tags.Name
}

output "public_subnet1" {
    value=aws_subnet.public_1
}
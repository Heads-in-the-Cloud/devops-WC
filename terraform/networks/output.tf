output "vpc_name"{
    value=aws_vpc.my_vpc.tags.Name
}
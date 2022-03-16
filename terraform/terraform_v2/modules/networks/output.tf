
output "vpc" {
  value = aws_vpc.my_vpc
}

output "subnet_group_id" {
  value = aws_db_subnet_group.private-subnet-group.id
}

output "public-subnet-ids" {
  value = [ aws_subnet.public_1.id, aws_subnet.public_2.id ]

}

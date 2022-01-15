
output "vpc" {
  value = aws_vpc.vpc
}


output "subnet_group_id" {
  value = aws_db_subnet_group.private-subnet-group.id
}

output "public-subnet-ids" {
  value = [ aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id ]

}
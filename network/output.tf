output "private_subnets" {
  value = [
    aws_subnet.app_a.id,
    aws_subnet.app_b.id
  ]
}
output "vpc_id" {
  value = aws_vpc.vpc.id
}
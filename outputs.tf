# VPC Id output
output "vpc_id" {
  description = "VPC id"
  value       = aws_vpc.vpc.id
}
# List of the private subnets id
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private.*.id
}
# List of the private subnets cidr block
output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = aws_subnet.private.*.cidr_block
}
# List of the public subnets id
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public.*.id
}
# List of the public subnets cidr block
output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = aws_subnet.public.*.cidr_block
}
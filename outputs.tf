################################################################################################################
###############################                  VPC                   #########################################
################################################################################################################

output "id" {
  value       = aws_vpc.this.id
  description = "The unique identifier of the created VPC. Use this ID as a reference in other modules or resources requiring VPC identification."
}

output "cidr_block" {
  value       = aws_vpc.this.cidr_block
  description = "The CIDR block of the created VPC."
}

################################################################################################################
###############################                SUBNETS                 #########################################
################################################################################################################

output "subnet_ids" {
  value = concat(
    [for subnet in aws_subnet.public : subnet.id],
    [for subnet in aws_subnet.private : subnet.id]
  )
  description = "The list of subnet IDs associated with the created VPC."
}

output "public_subnet_ids" {
  value       = [for subnet in aws_subnet.public : subnet.id]
  description = "The list of public subnet IDs associated with the created VPC."
}


output "private_subnet_ids" {
  value       = [for subnet in aws_subnet.private : subnet.id]
  description = "The list of private subnet IDs associated with the created VPC."
}

################################################################################################################
###############################              ROUTE-TABLES              #########################################
################################################################################################################

output "route_table_ids" {
  value = concat(
    [aws_vpc.this.default_route_table_id],
    [for route_table in aws_route_table.private : route_table.id]
  )
  description = "The list of route tables IDs associated with the created VPC."
}

output "default_route_table_id" {
  value       = [aws_vpc.this.default_route_table_id]
  description = "The ID of the default route table."
}

output "private_route_table_ids" {
  value       = [for route_table in aws_route_table.private : route_table.id]
  description = "The IDs of the private route tables."
}
# ------------------------------ VPC ------------------------------
output "vpc_id" {
  description = "The ID of the VPC"
  value       = try(local.vpc_id, null)
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = try(aws_vpc.vpc[0].arn, null)
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = try(aws_vpc.vpc[0].cidr_block, null)
}

# ------------------------------ DHCP Options Set ------------------------------
output "dhcp_options_id" {
  description = "The ID of the DHCP options"
  value       = try(aws_vpc_dhcp_options.dhcp_options[0].id, null)
}

# ------------------------------ Publiс Subnets ------------------------------
output "public_subnet_id" {
  description = "List of IDs of public subnets"
  value       = try(compact(aws_subnet.public[*].id), null)
}

output "public_subnet_arns" {
  description = "List of ARNs of public subnets"
  value       = try(compact(aws_subnet.public[*].arn), null)
}

output "public_subnet_cidr_block" {
  description = "List of cidr_blocks of public subnets"
  value       = try(compact(aws_subnet.public[*].cidr_block), null)
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = try(compact(aws_route_table.public[*].id), null)
}

output "public_route_table_association_ids" {
  description = "List of IDs of the public route table association"
  value       = try(compact(aws_route_table_association.public[*].id), null)
}

# ------------------------------ Public Network ACLs ------------------------------
output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = try(aws_network_acl.public[0].id, null)
}

output "public_network_acl_arn" {
  description = "ARN of the public network ACL"
  value       = try(aws_network_acl.public[0].arn, null)
}

# ------------------------------ Private Subnets ------------------------------
output "private_subnet_id" {
  description = "List of IDs of private subnets"
  value       = try(aws_subnet.private[*].id, null)
}

output "private_subnet_arns" {
  description = "List of ARNs of private subnets"
  value       = try(aws_subnet.private[*].arn, null)
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = try(compact(aws_subnet.private[*].cidr_block), null)
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = try(compact(aws_route_table.private[*].id), null)
}

output "private_route_table_association_ids" {
  description = "List of IDs of the private route table association"
  value       = try(compact(aws_route_table_association.private[*].id), null)
}

# ------------------------------ Private Network ACLs ------------------------------
output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = try(aws_network_acl.private[0].id, null)
}

output "private_network_acl_arn" {
  description = "ARN of the private network ACL"
  value       = try(aws_network_acl.private[0].arn, null)
}

# ------------------------------ Intra Subnets ------------------------------
output "intra_subnet_id" {
  description = "List of IDs of intra subnets"
  value       = try(compact(aws_subnet.intra[*].id), null)
}

output "intra_subnet_arns" {
  description = "List of ARNs of intra subnets"
  value       = try(compact(aws_subnet.intra[*].arn), null)
}

output "intra_subnets_cidr_blocks" {
  description = "List of cidr_blocks of intra subnets"
  value       = try(compact(aws_subnet.intra[*].cidr_block), null)
}

output "intra_route_table_ids" {
  description = "List of IDs of intra route tables"
  value       = try(aws_route_table.intra[*].id, null)
}

output "intra_route_table_association_ids" {
  description = "List of IDs of the intra route table association"
  value       = try(compact(aws_route_table_association.intra[*].id), null)
}

# ------------------------------ Intra Subnets ACLs ------------------------------
output "intra_network_acl_id" {
  description = "ID of the intra network ACL"
  value       = try(aws_network_acl.intra[0].id, null)
}

output "intra_network_acl_arn" {
  description = "ARN of the intra network ACL"
  value       = try(aws_network_acl.intra[0].arn, null)
}

# ------------------------------ Internet Gateway ------------------------------
output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = try(aws_internet_gateway.igw[0].id, null)
}

output "igw_arn" {
  description = "The ARN of the Internet Gateway"
  value       = try(aws_internet_gateway.igw[0].arn, null)
}

output "public_internet_gateway_route_id" {
  description = "ID of the internet gateway route"
  value       = try(aws_route.public_internet_gateway[0].id, null)
}

# ------------------------------ EIP ------------------------------
output "eip_public_ip" {
  description = "List of public ips of EIP"
  value       = try(compact(aws_eip.eip[*].public_ip), var.reuse_ips_ids[*], null)
}

output "eip_id" {
  description = "List of IDs of EIP"
  value       = try(compact(aws_eip.eip[*].id), null)
}

# ------------------------------ NAT Gateway ------------------------------
output "nat_gw_ids" {
  description = "List of NAT Gateway IDs"
  value       = try(aws_nat_gateway.nat_gw[*].id, null)
}

output "private_nat_gateway_route_ids" {
  description = "List of IDs of the private nat gateway route"
  value       = try(aws_route.private_nat_gateway[*].id, null)
}

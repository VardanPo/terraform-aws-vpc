# ------------------------------ Data ------------------------------
data "aws_availability_zones" "available" {}

# ------------------------------ Locals ------------------------------
locals {
  availability_zones = slice(data.aws_availability_zones.available.names, 0, var.availability_zones_count)
  vpc_id             = try(aws_vpc.vpc[0].id, var.vpc_id)
}

# ------------------------------ VPC ------------------------------
resource "aws_vpc" "vpc" {
  count = var.create_vpc ? 1 : 0

  cidr_block = var.vpc_cidr

  instance_tenancy                     = var.instance_tenancy
  enable_dns_hostnames                 = var.enable_dns_hostnames
  enable_dns_support                   = var.enable_dns_support
  enable_network_address_usage_metrics = var.enable_network_address_usage_metrics

  tags = merge(
    { "Name" = var.name },
    var.tags,
    var.vpc_tags,
  )
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr_blocks" {
  count = length(var.secondary_cidr_blocks) > 0 ? length(var.secondary_cidr_blocks) : 0

  vpc_id = local.vpc_id

  cidr_block = element(var.secondary_cidr_blocks, count.index)
}

# ------------------------------ DHCP Options Set ------------------------------
resource "aws_vpc_dhcp_options" "dhcp_options" {
  count = var.enable_dhcp_options ? 1 : 0

  domain_name          = var.dhcp_options_domain_name
  domain_name_servers  = var.dhcp_options_domain_name_servers
  ntp_servers          = var.dhcp_options_ntp_servers
  netbios_name_servers = var.dhcp_options_netbios_name_servers
  netbios_node_type    = var.dhcp_options_netbios_node_type

  tags = merge(
    var.tags,
    var.dhcp_options_tags,
  )
}

resource "aws_vpc_dhcp_options_association" "dhcp_options_association" {
  count = var.enable_dhcp_options ? 1 : 0

  vpc_id          = local.vpc_id
  dhcp_options_id = aws_vpc_dhcp_options.dhcp_options[0].id
}

# ------------------------------ Publiс Subnets ------------------------------
locals {
  create_public_subnets = length(var.public_subnets) > 0
}

resource "aws_subnet" "public" {
  count = local.create_public_subnets ? length(var.public_subnets) : 0

  availability_zone                           = var.public_subnets_az == null ? local.availability_zones[count.index] : var.public_subnets_az[count.index]
  cidr_block                                  = element(concat(var.public_subnets, [""]), count.index)
  enable_resource_name_dns_a_record_on_launch = var.public_subnet_enable_resource_name_dns_a_record_on_launch
  map_public_ip_on_launch                     = var.map_public_ip_on_launch
  private_dns_hostname_type_on_launch         = var.public_subnet_private_dns_hostname_type_on_launch
  vpc_id                                      = local.vpc_id

  tags = merge(
    {
      Name = try(
        var.public_subnet_names[count.index],
        format("${var.name}-${var.public_subnet_suffix}-%s", element(local.availability_zones, count.index))
      )
    },
    var.tags,
    var.public_subnet_tags,
  )
}

resource "aws_route_table" "public" {
  count = local.create_public_subnets ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = "${var.name}-${var.public_subnet_suffix}" },
    var.tags,
    var.public_route_table_tags
  )
}

resource "aws_route_table_association" "public" {
  count = local.create_public_subnets && var.create_public_route_table_association ? length(var.public_subnets) : 0

  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public[0].id
}

# ------------------------------ Public Network ACLs ------------------------------
locals {
  public_acl_subnet_ids = try(aws_subnet.public[*].id, var.public_acl_subnet_ids)
}

resource "aws_network_acl" "public" {
  count = var.public_dedicated_network_acl ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = local.public_acl_subnet_ids

  tags = merge(
    { "Name" = "${var.name}-${var.public_subnet_suffix}" },
    var.tags,
    var.public_acl_tags,
  )
}

resource "aws_network_acl_rule" "public_inbound" {
  count = var.public_dedicated_network_acl ? length(var.public_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress      = false
  rule_number = var.public_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.public_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.public_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.public_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.public_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "public_outbound" {
  count = var.public_dedicated_network_acl ? length(var.public_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.public[0].id

  egress      = true
  rule_number = var.public_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.public_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.public_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.public_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.public_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.public_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.public_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.public_outbound_acl_rules[count.index], "cidr_block", null)
}

# ------------------------------ Private Subnets ------------------------------
locals {
  create_private_subnets = length(var.private_subnets) > 0
}

resource "aws_subnet" "private" {
  count = local.create_private_subnets ? length(var.private_subnets) : 0

  availability_zone                           = var.private_subnets_az == null ? local.availability_zones[count.index] : var.private_subnets_az[count.index]
  cidr_block                                  = element(concat(var.private_subnets, [""]), count.index)
  enable_resource_name_dns_a_record_on_launch = var.private_subnet_enable_resource_name_dns_a_record_on_launch
  private_dns_hostname_type_on_launch         = var.private_subnet_private_dns_hostname_type_on_launch
  vpc_id                                      = local.vpc_id

  tags = merge(
    {
      Name = try(
        var.private_subnet_names[count.index],
        format("${var.name}-${var.private_subnet_suffix}-%s", element(local.availability_zones, count.index))
      )
    },
    var.tags,
    var.private_subnet_tags,
  )
}

resource "aws_route_table" "private" {
  count = local.create_private_subnets ? local.nat_gateway_count : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = var.single_nat_gateway ? "${var.name}-${var.private_subnet_suffix}" : format(
      "${var.name}-${var.private_subnet_suffix}-%s",
      element(local.availability_zones, count.index),
    ) },

    var.tags,
    var.private_route_table_tags
  )
}

resource "aws_route_table_association" "private" {
  count = local.create_private_subnets ? length(var.private_subnets) : 0

  subnet_id = element(aws_subnet.private[*].id, count.index)
  route_table_id = element(
    aws_route_table.private[*].id,
    var.single_nat_gateway ? 0 : count.index
  )
}

# ------------------------------ Private Network ACLs ------------------------------
locals {
  private_acl_subnet_ids = try(aws_subnet.private[*].id, var.private_acl_subnet_ids)
}

resource "aws_network_acl" "private" {
  count = var.private_dedicated_network_acl ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = local.private_acl_subnet_ids

  tags = merge(
    { "Name" = "${var.name}-${var.private_subnet_suffix}" },
    var.tags,
    var.private_acl_tags,
  )
}

resource "aws_network_acl_rule" "private_inbound" {
  count = var.private_dedicated_network_acl ? length(var.private_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress      = false
  rule_number = var.private_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.private_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.private_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.private_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.private_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.private_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.private_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.private_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "private_outbound" {
  count = var.private_dedicated_network_acl ? length(var.private_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.private[0].id

  egress      = true
  rule_number = var.private_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.private_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.private_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.private_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.private_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.private_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.private_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.private_outbound_acl_rules[count.index], "cidr_block", null)
}

# ------------------------------ Intra Subnets ------------------------------
locals {
  create_intra_subnets = length(var.intra_subnets) > 0
}

resource "aws_subnet" "intra" {
  count = local.create_intra_subnets ? length(var.intra_subnets) : 0

  availability_zone                           = local.availability_zones[count.index]
  cidr_block                                  = element(concat(var.intra_subnets, [""]), count.index)
  enable_resource_name_dns_a_record_on_launch = var.intra_subnet_enable_resource_name_dns_a_record_on_launch
  private_dns_hostname_type_on_launch         = var.intra_subnet_private_dns_hostname_type_on_launch
  vpc_id                                      = local.vpc_id

  tags = merge(
    {
      Name = try(
        var.intra_subnet_names[count.index],
        format("${var.name}-${var.intra_subnet_suffix}-%s", element(local.availability_zones, count.index))
      )
    },
    var.tags,
    var.intra_subnet_tags,
  )
}

resource "aws_route_table" "intra" {
  count = local.create_intra_subnets ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    { "Name" = "${var.name}-${var.intra_subnet_suffix}" },
    var.tags,
    var.intra_route_table_tags,
  )
}

resource "aws_route_table_association" "intra" {
  count = local.create_intra_subnets ? length(var.intra_subnets) : 0

  subnet_id      = element(aws_subnet.intra[*].id, count.index)
  route_table_id = element(aws_route_table.intra[*].id, 0)
}

# ------------------------------ Intra Subnets ACLs ------------------------------
locals {
  intra_acl_subnet_ids = try(aws_subnet.intra[*].id, var.intra_acl_subnet_ids)
}

resource "aws_network_acl" "intra" {
  count = var.intra_dedicated_network_acl ? 1 : 0

  vpc_id     = local.vpc_id
  subnet_ids = local.intra_acl_subnet_ids

  tags = merge(
    { "Name" = "${var.name}-${var.intra_subnet_suffix}" },
    var.tags,
    var.intra_acl_tags,
  )
}

resource "aws_network_acl_rule" "intra_inbound" {
  count = var.intra_dedicated_network_acl ? length(var.intra_inbound_acl_rules) : 0

  network_acl_id = aws_network_acl.intra[0].id

  egress      = false
  rule_number = var.intra_inbound_acl_rules[count.index]["rule_number"]
  rule_action = var.intra_inbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.intra_inbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.intra_inbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.intra_inbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.intra_inbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.intra_inbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.intra_inbound_acl_rules[count.index], "cidr_block", null)
}

resource "aws_network_acl_rule" "intra_outbound" {
  count = var.intra_dedicated_network_acl ? length(var.intra_outbound_acl_rules) : 0

  network_acl_id = aws_network_acl.intra[0].id

  egress      = true
  rule_number = var.intra_outbound_acl_rules[count.index]["rule_number"]
  rule_action = var.intra_outbound_acl_rules[count.index]["rule_action"]
  from_port   = lookup(var.intra_outbound_acl_rules[count.index], "from_port", null)
  to_port     = lookup(var.intra_outbound_acl_rules[count.index], "to_port", null)
  icmp_code   = lookup(var.intra_outbound_acl_rules[count.index], "icmp_code", null)
  icmp_type   = lookup(var.intra_outbound_acl_rules[count.index], "icmp_type", null)
  protocol    = var.intra_outbound_acl_rules[count.index]["protocol"]
  cidr_block  = lookup(var.intra_outbound_acl_rules[count.index], "cidr_block", null)
}

# ------------------------------ Internet Gateway ------------------------------
resource "aws_internet_gateway" "igw" {
  count = var.create_igw ? 1 : 0

  vpc_id = local.vpc_id

  tags = merge(
    var.tags,
    var.igw_tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count = local.create_public_subnets && var.create_igw ? 1 : 0

  route_table_id         = try(aws_route_table.public[0].id, var.igw_route_table_id)
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw[0].id
}

# ------------------------------ EIP ------------------------------
resource "aws_eip" "eip" {
  count = tobool(var.eip_count > 0) && !var.reuse_ips ? var.eip_count : 0

  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(local.availability_zones, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.eip_tags,
  )
}

# ------------------------------ NAT Gateway ------------------------------
locals {
  nat_gateway_count = var.single_nat_gateway ? 1 : var.one_nat_gateway_per_zone ? length(var.availability_zones_count) : length(var.private_subnets)
  nat_gateway_ips   = var.reuse_ips ? var.reuse_ips_ids : try(aws_eip.eip[*].id, [])
}


resource "aws_nat_gateway" "nat_gw" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  allocation_id = element(
    local.nat_gateway_ips,
    var.single_nat_gateway ? 0 : count.index,
  )
  subnet_id = element(
    try(aws_subnet.public[*].id, var.nat_gw_public_subnet_id[*]),
    var.single_nat_gateway ? 0 : count.index,
  )

  tags = merge(
    {
      "Name" = format(
        "${var.name}-%s",
        element(local.availability_zones, var.single_nat_gateway ? 0 : count.index),
      )
    },
    var.tags,
    var.nat_gw_tags,
  )
}

resource "aws_route" "private_nat_gateway" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0

  route_table_id         = element(try(aws_route_table.private[*].id, var.nat_gw_route_table_id[*]), count.index)
  destination_cidr_block = element(var.nat_gateway_destination_cidr_block, count.index)
  nat_gateway_id         = element(aws_nat_gateway.nat_gw[*].id, count.index)
}

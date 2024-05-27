# Terraform Module Documentation: AWS VPC

Terraform module which creates VPC resources (vpc, subnets, network acls, igw, eip, nat gw) on AWS.

## VPC

This part module is used to create a Virtual Private Cloud (VPC) in AWS. The module allows for the customization of various VPC settings, including CIDR block, secondary CIDR blocks, instance tenancy, DNS configurations, and tags.

### Usage Example

```
  module "vpc" {
    source = "path/to/module"

    name                           = "my-vpc"
    vpc_cidr                       = "10.0.0.0/16"
    instance_tenancy               = "default"
    enable_dns_hostnames           = true
    enable_dns_support             = true
    enable_network_address_metrics = true

    vpc_tags = {
      Environment = "production"
    }

    tags = {
      Owner = "John Doe"
    }
  }
```

## VPC DHCP Options

This part module is used to configure DHCP options for a Virtual Private Cloud (VPC) in AWS. The module allows for the customization of various DHCP options, including domain name, DNS servers, NTP servers, netbios servers, and netbios server type.

### Usage Example

```
module "vpc_dhcp_options" {
  source = "path/to/module"

  create_vpc                        = false
  vpc_id                            = "vpc-12345678"
  name                              = "my-vpc"
  enable_dhcp_options               = true
  dhcp_options_domain_name          = "example.com"
  dhcp_options_domain_name_servers  = ["10.0.0.2", "10.0.0.3"]
  dhcp_options_ntp_servers          = ["0.pool.ntp.org", "1.pool.ntp.org"]
  dhcp_options_netbios_name_servers = ["10.0.0.4", "10.0.0.5"]
  dhcp_options_netbios_node_type    = "2"

  dhcp_options_tags = {
    Environment = "production"
  }
}
```

In the above example, the module is instantiated with custom input values. The module configures DHCP options for the VPC with the ID `vpc-12345678`. The DHCP options include a custom domain name, DNS servers, NTP servers, netbios servers, and netbios server type.

The output of the module is accessed using the `module.vpc_dhcp_options` prefix, providing the resulting DHCP options ID for further use in the Terraform configuration.

Note: Replace `"path/to/module"` with the actual path or source location of the module.

## Subnets

This part module creates public, private, and intra subnets in a VPC along with their associated resources such as route tables and network ACLs.

### Usage Example

```
module "vpc" {
  source = "path/to/module"

  create_vpc = false
  vpc_id     = "vpc-12345678"
  name       = "my-vpc"
  
  availability_zones_count = 2
  
  public_subnets          = ["10.0.1.0/24", "10.0.2.0/24"]
  map_public_ip_on_launch = true

  public_subnet_tags = {
    type = "public-subnet"
  }

  public_route_table_tags = {
    Name = "route-public-subnets"
  }

  private_subnets = ["10.0.10.0/24", "10.0.20.0/24"]

  private_subnet_tags = {
    type = "private-subnet"
  }

  private_route_table_tags = {
    Name = "route-private-subnets"
  }
  
  intra_subnets = ["10.0.100.0/24", "10.0.200.0/24"]

  intra_subnet_tags = {
    type = "intra-subnet"
  }

  intra_route_table_tags = {
    Name = "intra-private-subnets"
  }
```

## Internet Gateway

This part module creates an AWS Internet Gateway and a corresponding route.

### Usage Example

```
module"igw" {
  source="path/to/module"

  create_vpc = false
  create_igw = true
  vpc_id     = "vpc-12345678"

  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24"]
  igw_route_table_id = "12345"
  
  igw_tags = {
    Environment = "Production"
    Project     = "MyProject"
  }
}
```

## EIP

This part module creates Elastic IP (EIP) resources in AWS.

### Usage Example

```
module "eip" {
  source     = "path/to/module"
  
  create_vpc = false
  eip_count  = 1

  eip_tags   = {
    Name = "MyEIP"
    Environment = "Production"
  }
}
```

The `eip_count` variable determines the number of EIPs to create. By default, no EIPs are created (`eip_count = 0`).

## NAT Gateway

This part module provisions NAT Gateways and associated routes for private networks in AWS.

### Usage Example

```
module "nat_gateway" {
  source     = "path/to/module"

  create_vpc                         = false
  single_nat_gateway                 = true
  enable_nat_gateway                 = true
  nat_gateway_destination_cidr_block = ["10.0.0.0/16", "192.168.0.0/16"]
  reuse_ips                          = false
  nat_gw_public_subnet_id            = ["subnet-12345678", "subnet-87654321"]
  nat_gw_route_table_id              = ["rtb-12345678", "rtb-87654321"]

  nat_gw_tags                      = {
    Environment = "Production"
    Project     = "MyProject"
  }
}
```

## Note for all

Replace `"path/to/module"` with the actual path or source location of the module.

## Module Inputs

The following are the input variables for this module:

* `vpc_id`: (Optional) The ID of the VPC in which the DHCP options will be associated. If not provided, the module will attempt to retrieve the VPC ID from an existing VPC. (Default: `""`)
* `create_vpc`: (Optional) Controls whether a new VPC should be created. Set to `true` to create a new VPC, or `false` to use an existing VPC. (Default: `true`)
* `name`: (Optional) The name of the VPC. This name will be used as an identifier for all associated resources. (Default: `""`)
* `vpc_cidr`: (Optional) The IPv4 CIDR block for the VPC. (Default: `"10.0.0.0/16"`)
* `secondary_cidr_blocks`: (Optional) A list of secondary CIDR blocks to associate with the VPC, extending the IP address pool. (Default: `[]`)
* `instance_tenancy`: (Optional) A tenancy option for instances launched into the VPC. (Default: `"default"`)
* `enable_dns_hostnames`: (Optional) Set to `true` to enable DNS hostnames in the VPC. (Default: `true`)
* `enable_dns_support`: (Optional) Set to `true` to enable DNS support in the VPC. (Default: `true`)
* `enable_network_address_usage_metrics`: (Optional) Determines whether network address usage metrics are enabled for the VPC. (Default: `null`)
* `vpc_tags`: (Optional) Additional tags for the VPC in the form of a map. (Default: `{}`)
* `tags`: (Optional) A map of tags to be added to all resources created by the module. (Default: `{}`)
* `enable_dhcp_options`: (Optional) Set to `true` if you want to specify custom DHCP options for the VPC. (Default: `false`)
* `dhcp_options_domain_name`: (Requires enable_dhcp_options set to true) The DNS name for the DHCP options set. (Default: `""`)
* `dhcp_options_domain_name_servers`: (Requires enable_dhcp_options set to true) A list of DNS server addresses for the DHCP options set. Default is set to AWS provided DNS servers. (Default: `["AmazonProvidedDNS"]`)
* `dhcp_options_ntp_servers`: (Requires enable_dhcp_options set to true) A list of NTP server addresses for the DHCP options set. (Default: `[]`)
* `dhcp_options_netbios_name_servers`: (Requires enable_dhcp_options set to true) A list of netbios server addresses for the DHCP options set. (Default: `[]`)
* `dhcp_options_netbios_node_type`: (Requires enable_dhcp_options set to true) The netbios node type for the DHCP options set. (Default: `""`)
* `dhcp_options_tags`: (Optional) Additional tags for the DHCP option set. (Default: `{}`)
* `public_subnets`: (Optional) A list of public subnets inside the VPC. (Default: `[]`)
* `ailability_zones_count`: (Optional) A count of availability zones when creating resources. (Default: `3`)
* `public_subnet_enable_resource_name_dns_a_record_on_launch`: (Optional) Indicates whether to respond to DNS queries for instance hostnames with DNS A records. (Default: `false`)
* `map_public_ip_on_launch`: (Optional) Specify true to indicate that instances launched into the subnet should be assigned a public IP address. (Default: `false`)
* `public_subnet_private_dns_hostname_type_on_launch`: (Optional) The type of hostnames to assign to instances in the subnet at launch. (Default: `null`)
* `public_subnet_names`: (Optional) Explicit values to use in the Name tag on public subnets. If empty, Name tags are generated. (Default: `[]`)
* `public_subnet_suffix`: (Optional) Suffix to append to public subnets name. (Default: `public`)
* `public_subnet_tags`: (Optional) Additional tags for the public subnets. (Default: `{}`)
* `public_route_table_tags`: (Optional) Additional tags for the public route tables. (Default: `{}`)
* `public_dedicated_network_acl`: (Optional) Whether to use dedicated network ACL (not default) and custom rules for public subnets. (Default: `false`)
* `public_acl_subnet_ids`: (Optional) Set custem public subnets ids for ACL. (Default: `[]`)
* `public_inbound_acl_rules`: (Optional) Public subnets inbound network ACLs. (Default: `list(map(string)` see in module)
* `public_outbound_acl_rules`: (Optional) Public subnets outbound network ACLs. (Default: `list(map(string)` see in module)
* `public_acl_tags`: (Optional) Additional tags for the public subnets network ACL. (Default: `{}`)
* `private_subnets`: (Optional) A list of private subnets inside the VPC. (Default: `[]`)
* `private_subnet_enable_resource_name_dns_a_record_on_launch`: (Optional) Indicates whether to respond to DNS queries for instance hostnames with DNS A records. (Default: `false`)
* `private_subnet_private_dns_hostname_type_on_launch`: (Optional) The type of hostnames to assign to instances in the subnet at launch. (Default: `null`)
* `private_subnet_names`: (Optional) Explicit values to use in the Name tag on private subnets. If empty, Name tags are generated. (Default: `[]`)
* `private_subnet_suffix`: (Optional) Suffix to append to private subnets name. (Default: `private`)
* `private_subnet_tags`: (Optional) Additional tags for the private subnets. (Default: `{}`)
* `private_route_table_tags`: (Optional) Additional tags for the private route tables. (Default: `{}`)
* `private_dedicated_network_acl`: (Optional) Whether to use dedicated network ACL (not default) and custom rules for private subnets. (Default: `false`)
* `private_acl_subnet_ids`: (Optional) Set custem private subnets ids for ACL. (Default: `[]`)
* `private_inbound_acl_rules`: (Optional) Private subnets inbound network ACLs. (Default: `list(map(string)` see in module)
* `private_outbound_acl_rules`: (Optional) Private subnets outbound network ACLs. (Default: `list(map(string)` see in module)
* `private_acl_tags`: (Optional) Additional tags for the private subnets network ACL. (Default: `{}`)
* `intra_subnets`: (Optional) A list of intra subnets inside the VPC. (Default: `[]`)
* `intra_subnet_enable_resource_name_dns_a_record_on_launch`: (Optional) Indicates whether to respond to DNS queries for instance hostnames with DNS A records. (Default: `false`)
* `intra_subnet_private_dns_hostname_type_on_launch`: (Optional) The type of hostnames to assign to instances in the subnet at launch. (Default: `null`)
* `intra_subnet_names`: (Optional) Explicit values to use in the Name tag on intra subnets. If empty, Name tags are generated. (Default: `[]`)
* `intra_subnet_suffix`: (Optional) Suffix to append to intra subnets name. (Default: `intra`)
* `intra_subnet_tags`: (Optional) Additional tags for the intra subnets. (Default: `{}`)
* `intra_route_table_tags`: (Optional) Additional tags for the intra route tables. (Default: `{}`)
* `intra_dedicated_network_acl`: (Optional) Whether to use dedicated network ACL (not default) and custom rules for intra subnets. (Default: `false`)
* `intra_acl_subnet_ids`: (Optional) Set custem intra subnets ids for ACL. (Default: `[]`)
* `intra_inbound_acl_rules`: (Optional) Intra subnets inbound network ACLs. (Default: `list(map(string)` see in module)
* `intra_outbound_acl_rules`: (Optional) Intra subnets outbound network ACLs. (Default: `list(map(string)` see in module)
* `intra_acl_tags`: (Optional) Additional tags for the intra subnets network ACL. (Default: `{}`)
* `create_igw`: (Optional) Controls if an Internet Gateway is created for public subnets and the related routes that connect them. (Default: `false`)
* `igw_route_table_id`: (Optional) Custem route table id for igw route. (Default: `null`)
* `igw_tags`: (Optional) Additional tags for the internet gateway. (Default: `{}`)
* `eip_count`: (Optional) Count for creating EIP. (Default: `0`)
* `eip_tags`: (Optional) Additional tags for the EIP. (Default: `{}`)
* `single_nat_gateway`: (Optional) Should be true if you want to provision a single shared NAT Gateway across all of your private networks. (Default: `false`)
* `one_nat_gateway_per_zone`: (Optional) Should be true if you want only one NAT Gateway per availability zone. (Default: `false`)
* `enable_nat_gateway`: (Optional) Should be true if you want to provision NAT Gateways for each of your private networks. (Default: `false`)
* `nat_gateway_destination_cidr_block`: (Optional) Used to pass a custom destination route for private NAT Gateway. If not specified, the default 0.0.0.0/0 is used as a destination route. (Default:` ["0.0.0.0/0"]`)
* `reuse_ips`: (Optional) Should be true if you don't want EIPs to be created for your NAT Gateways and will instead pass them in via the 'reuse_ips_ids' variable. (Default: `false`)
* `reuse_ips_ids`: (Optional) List of EIP IDs to be assigned to the NAT Gateways (used in combination with reuse_ips). (Default: `[]`)
* `nat_gw_public_subnet_id`: (Optional) Custem list of public subnets ids for nat gw attachment. (Default: `[]`)
* `nat_gw_route_table_id`: (Optional) Custem list of route tables ids for nat gw private route. (Default: `[]`)
* `nat_gw_tags`: (Optional) Additional tags for the NAT gateways. (Default: `{}`)

## Module Outputs

The module provides the following outputs:

* `vpc_id`: The ID of the VPC created or used by the module.
* `vpc_arn`: The ARN (Amazon Resource Name) of the VPC.
* `vpc_cidr_block`: The CIDR block of the VPC.
* `dhcp_options_id`: The ID of the DHCP options set.
* `public_subnet_id`: List of IDs of public subnets.
* `public_subnet_arns`: List of ARNs of public subnets.
* `public_subnet_cidr_block`: List of cidr_blocks of public subnets.
* `public_route_table_ids`: List of IDs of public route tables.
* `public_route_table_association_ids`: List of IDs of the public route table association.
* `public_network_acl_id`: ID of the public network ACL.
* `public_network_acl_arn`: ARN of the public network ACL.
* `private_subnet_id`: List of IDs of private subnets.
* `private_subnet_arns`: List of ARNs of private subnets.
* `private_subnets_cidr_blocks`: List of cidr_blocks of private subnets.
* `private_route_table_ids`: List of IDs of private route tables.
* `private_route_table_association_ids`: List of IDs of the private route table association.
* `private_network_acl_id`: ID of the private network ACL.
* `private_network_acl_arn`: ARN of the private network ACL.
* `intra_subnet`: List of IDs of intra subnets.
* `intra_subnet_arns`: List of ARNs of intra subnets.
* `intra_subnets_cidr_blocks`: List of cidr_blocks of intra subnets.
* `intra_route_table_ids`: List of IDs of intra route tables.
* `intra_route_table_association_ids`: List of IDs of the intra route table association.
* `intra_network_acl_id`: ID of the intra network ACL.
* `intra_network_acl_arn`: ARN of the intra network ACL.
* `igw_id`: The ID of the Internet Gateway.
* `igw_arn`: The ARN of the Internet Gateway.
* `public_internet_gateway_route_id`: ID of the internet gateway route.
* `eip_public_ip`: List of public ips of EIP.
* `eip_id`: List of IDs of EIP.
* `nat_gw_ids`: List of NAT Gateway IDs.
* `private_nat_gateway_route_ids`: List of IDs of the private nat gateway route.

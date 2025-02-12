################################################################################################################
###############################                  VPC                   #########################################
################################################################################################################

# This Terraform resource block defines an AWS Virtual Private Cloud (VPC) configuration.
# It allows customization of VPC settings such as CIDR block, DNS support, and DNS hostnames.
# Tags are also applied for easy identification and management within AWS.
# tfsec:ignore:AVD-AWS-0178
resource "aws_vpc" "this" {

  # VPC settings.
  cidr_block           = var.cidr_block
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  # Add name tag and any additional extra tags specified as variable.
  tags = merge(
    { Name = var.name },
    var.extra_tags
  )

}

################################################################################################################
###############################                  IGW                   #########################################
################################################################################################################

# This Terraform resource block defines the creation of an Internet Gateway (IGW) for the VPC.
# An Internet Gateway allows communication between instances in the VPC and the internet.
resource "aws_internet_gateway" "this" {

  # IGW settings.
  vpc_id = aws_vpc.this.id

  # Add name tag and any additional extra tags specified as variable.
  tags = merge(
    { Name = "${var.name}-vpc-igw" },
    var.extra_tags
  )

}

################################################################################################################
###############################                SUBNETS                 #########################################
################################################################################################################

# This Terraform resource block defines the creation of public subnets within the VPC. 
# Public subnets typically host resources that require direct access to the internet. 
# Each public subnet is associated with an availability zone and can optionally have public IP addresses mapped to instances launched within it.
resource "aws_subnet" "public" {

  # Create a subnet for each CIDR block specified in the 'public_subnets' variable.
  for_each = { for idx, cidr in var.public_subnets : idx => cidr }

  # Subnet settings.
  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = element(local.azs, each.key)
  map_public_ip_on_launch = var.map_public_ip_on_launch

  # Add name tag and any additional extra tags specified as variable.
  tags = merge(
    { Name = format("${var.name}-vpc-%s-${var.public_subnet_suffix}", element(local.azs, each.key)) },
    var.extra_tags
  )

}

# This Terraform resource block defines the creation of private subnets within the VPC. 
# Private subnets are typically used for resources that do not require direct internet access. 
# They are associated with specific availability zones and are suitable for hosting internal-facing resources.
resource "aws_subnet" "private" {

  # Create a subnet for each CIDR block specified in the 'private_subnets' variable.
  for_each = { for idx, cidr in var.private_subnets : idx => cidr }

  # Subnet settings.
  vpc_id            = aws_vpc.this.id
  cidr_block        = each.value
  availability_zone = element(local.azs, each.key)

  # Add name tag and any additional extra tags specified as variable.
  tags = merge(
    { Name = format("${var.name}-vpc-%s-${var.private_subnet_suffix}", element(local.azs, each.key)) },
    var.extra_tags
  )

}

################################################################################################################
###############################              ROUTE-TABLES              #########################################
################################################################################################################

# This Terraform resource block defines the creation of a route table for public subnets within the VPC.
# Route tables are used to define how network traffic should be directed within the VPC.
resource "aws_default_route_table" "this" {

  # Associate the route table with the VPC.
  default_route_table_id = aws_vpc.this.default_route_table_id

  # Define a route for internet access via the Internet Gateway.
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  # Prevent the route table from being replaced during updates.
  # This is to avoid accidental changes to the route table configuration.
  lifecycle {
    ignore_changes = [
      route
    ]
  }

  # Add name tag and any additional extra tags specified as variable.
  tags = merge(
    { Name = "${var.name}-vpc-default-rtb" },
    var.extra_tags
  )

}

# This Terraform resource block defines the creation of a route table for private subnets within the VPC.
# It's used to route outbound traffic from private subnets to the NAT Gateway.
resource "aws_route_table" "private" {

  # Create a route table for each private subnet.
  for_each = length(var.private_subnets) > 0 ? (
    var.single_nat ? {
      "single" = try(aws_nat_gateway.this["single"].id, null)
      } : {
      for idx, _ in aws_subnet.public :
      tostring(idx) => try(aws_nat_gateway.this[idx].id, null)
    }
  ) : {}

  vpc_id = aws_vpc.this.id

  # Prevent the route table from being replaced during updates.
  # This is to avoid accidental changes to the route table configuration.
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = each.value
  }

  # Add name tag and any additional extra tags specified as variable.
  tags = merge(
    { Name = var.single_nat ? "${var.name}-vpc-shared-rtb" : format("${var.name}-vpc-%s-rtb", element(local.azs, each.key)) },
    var.extra_tags
  )

}

# This Terraform resource block defines the association of private subnets with the private route table.
# It ensures that outbound traffic from private subnets is routed through the NAT Gateway.
resource "aws_route_table_association" "private" {

  # Create an association for each private subnet with the corresponding route table.
  for_each = {
    for subnet_key, subnet in aws_subnet.private :
    tostring(subnet_key) => {
      subnet_id      = subnet.id
      route_table_id = var.single_nat ? aws_route_table.private["single"].id : aws_route_table.private[subnet_key].id
    }
  }

  # Associate the private subnet with the private route table.
  subnet_id      = each.value.subnet_id
  route_table_id = each.value.route_table_id

}

# This Terraform resource block defines the association of public subnets with the public route table.
# Each public subnet in the VPC is associated with the public route table to manage the routing of network traffic.
resource "aws_route_table_association" "public" {

  # Create an association for each public subnet with the default route table.
  for_each = { for idx, subnet in aws_subnet.public : idx => subnet }

  # Associate the public subnet with the default route table.
  subnet_id      = each.value.id
  route_table_id = aws_default_route_table.this.id

}

################################################################################################################
###############################                  EIP                   #########################################
################################################################################################################

# This Terraform resource block defines the creation of Elastic IPs (EIPs) for NAT Gateways.
# Depending on the configuration, it either creates a single shared EIP for a NAT Gateway serving all private 
# networks or creates individual EIPs for each private subnet within the VPC.
resource "aws_eip" "ngw" {

  # Only create the EIP if there are private subnets.
  for_each = length(var.private_subnets) > 0 ? (
    var.single_nat ? { single = 1 } : { for idx, _ in var.private_subnets : idx => idx }
  ) : {}

  # Add name tag and any additional extra tags specified as variable.
  tags = merge(
    { Name = var.single_nat ? "${var.name}-vpc-shared-ngw" : format("${var.name}-vpc-%s-ngw", element(local.azs, each.key)) },
    var.extra_tags
  )

}

################################################################################################################
###############################              NAT-GATEWAY               #########################################
################################################################################################################

# This Terraform resource block defines the creation of a NAT Gateway in each public subnet for outbound internet traffic.
# NAT Gateways allow instances in private subnets to initiate outbound traffic to the internet while preventing inbound traffic
# from initiating a connection with them.
resource "aws_nat_gateway" "this" {

  # Only create the NAT Gateway if there are private subnets.
  for_each = length(var.private_subnets) > 0 ? (
    var.single_nat ? { single = try(values(aws_subnet.public)[0].id, null) } : { for idx, subnet in aws_subnet.public : idx => subnet.id }
  ) : {}

  # Associate the NAT Gateway with the corresponding Elastic IP.
  subnet_id     = each.value
  allocation_id = var.single_nat ? aws_eip.ngw["single"].id : aws_eip.ngw[each.key].id

  # Add name tag and any additional extra tags specified as variable.
  tags = merge(
    { Name = var.single_nat ? "${var.name}-vpc-shared-ngw" : format("${var.name}-vpc-%s-ngw", element(local.azs, each.key)) },
    var.extra_tags
  )

}
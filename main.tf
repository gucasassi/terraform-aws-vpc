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
    { Name = "${var.name}-vpc" },
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
    { Name = "${var.name}-vpc-default" },
    var.extra_tags
  )

}
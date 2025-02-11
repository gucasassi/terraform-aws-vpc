# terraform-aws-vpc
This repository contains a Terraform module for creating and configuring a VPC in AWS with native IPv6 support. It is designed to simplify cloud infrastructure deployment.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.5.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.27 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.86.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_default_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cidr_block"></a> [cidr\_block](#input\_cidr\_block) | The IPv4 CIDR block for the VPC. If not provided, a default CIDR block will be used. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_enable_dns_hostnames"></a> [enable\_dns\_hostnames](#input\_enable\_dns\_hostnames) | Set to true to enable DNS hostnames for the instances launched in the VPC. | `bool` | `true` | no |
| <a name="input_enable_dns_support"></a> [enable\_dns\_support](#input\_enable\_dns\_support) | Set to true to enable DNS support within the VPC. | `bool` | `true` | no |
| <a name="input_extra_tags"></a> [extra\_tags](#input\_extra\_tags) | A map of extra tags to add to all resources created by the module. | `map(string)` | `{}` | no |
| <a name="input_map_public_ip_on_launch"></a> [map\_public\_ip\_on\_launch](#input\_map\_public\_ip\_on\_launch) | Set to true to assign public IP addresses to instances launched within the subnet. Defaults to `false`. | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | A unique name used as an identifier for all resources created by this module. | `string` | n/a | yes |
| <a name="input_public_subnet_suffix"></a> [public\_subnet\_suffix](#input\_public\_subnet\_suffix) | A suffix to append to the names of the public subnets. | `string` | `"public"` | no |
| <a name="input_public_subnets"></a> [public\_subnets](#input\_public\_subnets) | A list of CIDR blocks for the public subnets to be created inside the VPC. | `list(string)` | <pre>[<br/>  "10.0.0.0/22",<br/>  "10.0.4.0/22"<br/>]</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
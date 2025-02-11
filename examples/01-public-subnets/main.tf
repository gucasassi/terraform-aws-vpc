# Example of how to use the module.
module "vpc" {

  # Module source.
  source = "../.."

  # Module variables.
  name           = var.vpc_name
  cidr_block     = var.vpc_cidr_block
  public_subnets = var.vpc_public_subnets

}
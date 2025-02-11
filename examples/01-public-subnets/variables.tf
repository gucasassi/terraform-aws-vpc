################################################################################################################
###############################                  AWS                   #########################################
################################################################################################################

variable "aws_region" {
  description = "The AWS region in which to create resources."
  type        = string
  default     = "eu-west-1"
}

################################################################################################################
###############################                  VPC                   #########################################
################################################################################################################

variable "vpc_name" {
  description = "The name of the VPC to create"
  type        = string
  default     = "morgoth"
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "vpc_public_subnets" {
  description = "A list of public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"]
}
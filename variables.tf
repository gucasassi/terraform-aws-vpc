################################################################################################################
###############################                  VPC                   #########################################
################################################################################################################

variable "name" {
  description = "A unique name used as an identifier for all resources created by this module."
  type        = string
}

variable "cidr_block" {
  description = "The IPv4 CIDR block for the VPC. If not provided, a default CIDR block will be used."
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_dns_support" {
  description = "Set to true to enable DNS support within the VPC."
  type        = bool
  default     = true
}

variable "enable_dns_hostnames" {
  description = "Set to true to enable DNS hostnames for the instances launched in the VPC."
  type        = bool
  default     = true
}

################################################################################################################
###############################                SUBNETS                 #########################################
################################################################################################################

variable "public_subnets" {
  description = "A list of CIDR blocks for the public subnets to be created inside the VPC."
  type        = list(string)
  default     = ["10.0.0.0/22", "10.0.4.0/22"]
}

variable "public_subnet_suffix" {
  description = "A suffix to append to the names of the public subnets."
  type        = string
  default     = "public"
}

variable "map_public_ip_on_launch" {
  description = "Set to true to assign public IP addresses to instances launched within the subnet. Defaults to `false`."
  type        = bool
  default     = false
}

################################################################################################################
###############################                 TAGS                   #########################################
################################################################################################################

variable "extra_tags" {
  description = "A map of extra tags to add to all resources created by the module."
  type        = map(string)
  default     = {}
}
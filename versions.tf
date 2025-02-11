# Define terraform and provider versions.
terraform {
  # Specifies the required version of terraform.
  required_version = "~> 1.5.4"

  # Specifies the required providers.
  required_providers {
    # AWS provider.
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.27"
    }
  }
}

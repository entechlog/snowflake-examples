# -------------------------------------------------------------------------
# Terraform configuration block to specify required providers
# -------------------------------------------------------------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.59.0"
    }
  }
}

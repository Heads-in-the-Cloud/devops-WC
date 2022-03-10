terraform {
  backend "s3" {
    bucket = "WC-terraform-state-${var.environment}"
    key    = "network/terraform.tfstate"
    region = var.region
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.region
  shared_credentials_file = "$HOME/.aws/credentials"
}
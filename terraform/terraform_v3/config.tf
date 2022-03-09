terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
      bucket = "WC-terraform-state-prod"
      key    = "network/terraform.tfstate"
      region = var.region
    }
}
terraform {
  backend "s3" {
    bucket = "utopia-bucket-wc"
    key    = "terraform/rds/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "WC_terraform_state"
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
  region                  =  var.region
  shared_credentials_file = "$HOME/.aws/credentials"
}

terraform {
  backend "s3" {
    bucket = "utopia-bucket-wc"
    key    = "network/terraform.tfstate"
    region = "us-west-2"
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

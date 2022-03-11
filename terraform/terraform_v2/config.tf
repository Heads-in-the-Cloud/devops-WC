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

# provider "aws" {
#   alias                   = "us_west_1"
#   region                  = "us-west-1"
#   shared_credentials_file = "$HOME/.aws/credentials"
# }

# provider "aws" {
#   alias                   = "us_east_1"
#   region                  = "us-east-1"
#   shared_credentials_file = "$HOME/.aws/credentials"
# }

# provider "aws" {
#   alias                   = "us_east_2"
#   region                  = "us-east-2"
#   shared_credentials_file = "$HOME/.aws/credentials"
# }
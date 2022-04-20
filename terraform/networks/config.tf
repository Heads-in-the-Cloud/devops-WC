terraform {
  backend "s3" {
    bucket = "utopia-bucket-wc"
    key    = "terraform/${ENVIRONMENT}/${REGION_WC}/networks/terraform.tfstate"
    region = "${REGION_WC}"
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

provider "aws" {
  alias  = "home"
  region = "us-west-2"
}

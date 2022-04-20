terraform {
  backend "s3" {
    bucket = "utopia-bucket-wc"
    key    = "terraform/${ENVIRONMENT}/${WC_REGION}/networks/terraform.tfstate"
    region = "${WC_REGION}"
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

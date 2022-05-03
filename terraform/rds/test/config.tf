terraform {
  backend "s3" {
    bucket = "utopia-bucket-wc"
    key    = "terraform/${ENVIRONMENT}/${REGION_WC}/connections_test/terraform.tfstate"
    region = "us-west-2"
    dynamodb_table = "WC_terraform_state"
  }
}

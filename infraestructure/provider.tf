terraform {
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = var.region
}

provider "aws" {
  region = var.replica_region

  alias = "replica"

  # Make it faster by skipping something, only for s3 bucket replication cross region
  skip_get_ec2_platforms      = true
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}
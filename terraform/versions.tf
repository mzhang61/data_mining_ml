terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  # Store state remotely in S3
  # We created the state bucket FIRST (a different bucket from the data one below)
  #
  backend "s3" {
    bucket       = "csc555-project-mzhang61"
    key          = "emr-s3/terraform.tfstate"
    region       = "us-east-2"
    use_lockfile = true # S3-native state locking (Terraform >= 1.10)
  }
}

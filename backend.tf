terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    region  = "ap-southeast-2"
    profile = "default"
    key     = "terraformstatefile"
    bucket  = "terraformstatebackendkt-iac-1"
  }
}



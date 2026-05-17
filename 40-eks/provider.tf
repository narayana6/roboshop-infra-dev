terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 5.95.0, < 6.0.0"
    }
  }

  backend "s3" {
    bucket = "bnsaws-remote-state-dev"
    key    = "roboshop-eks"
    region = "us-east-1"
    dynamodb_table = "bnsaws-locking-dev"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.82.0"
    }
  }

  backend "s3" {
    bucket = "bnsaws-remote-state-dev"
    key    = "roboshop-alb-ingress"
    region = "us-east-1"
    dynamodb_table = "bnsaws-locking-dev"
  }
}

provider "aws" {
  # Configuration options
  region = "us-east-1"
}
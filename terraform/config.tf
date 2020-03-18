provider "aws" {
  version = "~> 2.53.0"
  region  = var.aws_region
}

terraform {
  backend "s3" {
    region  = "us-east-1"
    encrypt = "true"
  }
}
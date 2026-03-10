terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.57.0"
    }
  }
  backend "s3" {
    bucket = var.backend_bucket
    key    = var.backend_key
    region = var.region
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

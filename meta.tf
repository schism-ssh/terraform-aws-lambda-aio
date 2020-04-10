terraform {
  required_providers {
    aws = "~> 2.56"
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" current {}

provider "aws" {
  region  = "us-west-2"
  version = "~> 2.57"
}

variable "prefix" {}
variable "lambda_s3_bucket" {}

module "schism" {
  source = "../"

  prefix           = var.prefix
  lambda_s3_bucket = var.lambda_s3_bucket
}

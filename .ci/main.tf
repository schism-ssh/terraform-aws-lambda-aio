provider "aws" {
  region = "us-west-2"
}

variable "prefix" {}
variable "lambda_s3" {}

module "schism" {
  source = "../"

  prefix    = var.prefix
  lambda_s3 = var.lambda_s3
}

variable "prefix" {
  default = "schism-aio"
}

variable "lambda_s3_bucket" {
  default = "your_bucket_here"
}

variable "lambda_s3_prefix" {
  default = "lambdas/schism"
}

variable "lambda_function" {
  default = {
    controller = {
      name    = "controller"
      version = "v0.1.1"
      timeout = 900
      runtime = "go1.x"
    }
  }
}

variable "kms_key" {
  default = {
    ca_certs = {
      key_id = ""
    }
  }
}

variable "ssm" {
  default = {
    host_ca_param_name = "schism-host-ca-key"
    user_ca_param_name = "schism-user-ca-key"
  }
}

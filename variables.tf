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
      version = "v0.4.0"
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
    signed_certs = {
      key_id = ""
    }
  }
}

variable "ssm" {
  default = {
    ca_param_prefix = "ca-key"
  }
}

variable "s3_store" {
  default = {
    name      = "certificates"
    versioned = false
    # access_logging requires existing log bucket
    access_logging = {
      enabled       = false
      target_bucket = null
      # target_prefix is the same name as the bucket
    }
  }
}

variable "host_ca_auth_domain" {
  default = "example.com"
}

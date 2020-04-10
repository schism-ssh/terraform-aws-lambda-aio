resource "aws_lambda_function" "controller" {
  s3_bucket = var.lambda_s3.s3_bucket
  s3_key    = "${var.lambda_s3.s3_prefix}/schism-lambda-${var.lambda_function.controller.version}.zip"

  function_name = "${var.prefix}-${var.lambda_function.controller.name}"
  handler       = "schism-lambda-${var.lambda_function.controller.version}"

  role = aws_iam_role.lambda_controller.arn

  runtime = var.lambda_function.controller.runtime
  timeout = var.lambda_function.controller.timeout

  environment {
    variables {
      SCHISM_CA_KMS_KEY_ID      = var.kms_key.ca_certs.key_id
      SCHISM_HOST_CA_PARAM_NAME = "${var.prefix}-${var.ssm.host_ca_param_name}"
      SCHISM_USER_CA_PARAM_NAME = "${var.prefix}-${var.ssm.user_ca_param_name}"
    }
  }
}
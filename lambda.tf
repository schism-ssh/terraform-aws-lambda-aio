resource "aws_lambda_function" "controller" {
  s3_bucket = var.lambda_s3_bucket
  s3_key    = "${var.lambda_s3_prefix}/schism-lambda-${var.lambda_function.controller.version}.zip"

  function_name = "${var.prefix}-${var.lambda_function.controller.name}"
  handler       = "schism-lambda-${var.lambda_function.controller.version}"

  role = aws_iam_role.lambda_controller.arn

  runtime = var.lambda_function.controller.runtime
  timeout = var.lambda_function.controller.timeout

  depends_on = [
    aws_iam_role_policy_attachment.controller_certificate_mgmt_ssm,
    aws_iam_role_policy_attachment.controller_cloudwatch_mgmt
  ]

  environment {
    variables = {
      SCHISM_CA_KMS_KEY_ID   = var.kms_key.ca_certs.key_id
      SCHISM_CA_PARAM_PREFIX = "${var.prefix}-${var.ssm.ca_param_prefix}"
    }
  }
}

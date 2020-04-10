data "aws_iam_policy_document" "manage_ca_certificates" {
  statement {
    sid = "ManageCACertificates"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/${var.prefix}-${var.ssm.host_ca_param_name}",
      "arn:aws:ssm:*:*:parameter/${var.prefix}-${var.ssm.user_ca_param_name}",
      "arn:aws:kms:*:*:key/${var.kms_key.ca_certs.key_id}"
    ]
  }
}
resource "aws_iam_policy" "manage_ca_certificates" {
  name = "${var.prefix}-manage-ca-certificates"

  policy = data.aws_iam_policy_document.manage_ca_certificates.json
}

data "aws_iam_policy_document" "manage_lambda_controller_cloudwatch" {
  dynamic "statement" {
    for_each = {
      CreateLogGroups : "",
      CreateLogStream : ":log-stream:*",
      PutLogEvents : ":log-stream:*"
    }
    content {
      sid = "CloudWatchLambda${statement.key}"
      actions = [
        "logs:${statement.key}"
      ]
      resources = [
        join(":", [
          "arn:aws:logs",
          data.aws_region.current.name,
          data.aws_caller_identity.current.account_id,
          "log-group:/aws/lambda/${aws_lambda_function.controller.function_name}${statement.value}"
        ])
      ]
    }
  }
}
resource "aws_iam_policy" "manage_lambda_controller_cloudwatch" {
  name   = "${var.prefix}-manage-lambda-controller-cloudwatch"
  policy = data.aws_iam_policy_document.manage_lambda_controller_cloudwatch.json
}

data "aws_iam_policy_document" "lambda_controller" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_controller" {
  name               = "${var.prefix}-${var.lambda_function.controller.name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_controller.json
}

resource "aws_iam_role_policy_attachment" "controller_certificate_mgmt" {
  role       = aws_iam_role.lambda_controller.name
  policy_arn = aws_iam_policy.manage_ca_certificates.arn
}
resource "aws_iam_role_policy_attachment" "controller_cloudwatch_mgmt" {
  role       = aws_iam_role.lambda_controller.name
  policy_arn = aws_iam_policy.manage_lambda_controller_cloudwatch.arn
}

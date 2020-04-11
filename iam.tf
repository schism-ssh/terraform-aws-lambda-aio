data "aws_iam_policy_document" "manage_ca_certificates_ssm" {
  statement {
    sid = "ManageCACertificatesSSM"
    actions = [
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/${var.prefix}-${var.ssm.host_ca_param_name}",
      "arn:aws:ssm:*:*:parameter/${var.prefix}-${var.ssm.user_ca_param_name}"
    ]
  }
}
resource "aws_iam_policy" "manage_ca_certificates_ssm" {
  name = "${var.prefix}-manage-ca-certificates-ssm"

  policy = data.aws_iam_policy_document.manage_ca_certificates_ssm.json
}

data "aws_iam_policy_document" "manage_ca_certificates_kms" {
  count = length(var.kms_key.ca_certs.key_id) == 0 ? 0 : 1
  statement {
    sid = "ManageCACertificatesKMS"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = ["arn:aws:kms:*:*:key/${var.kms_key.ca_certs.key_id}"]
  }
}
resource "aws_iam_policy" "manage_ca_certificates_kms" {
  count = length(data.aws_iam_policy_document.manage_ca_certificates_kms) == 0 ? 0 : 1
  name  = "${var.prefix}-manage-ca-certificates-kms"

  policy = data.aws_iam_policy_document.manage_ca_certificates_kms[count.index].json
}

data "aws_iam_policy_document" "manage_lambda_controller_cloudwatch" {
  statement {
    sid       = "CloudWatchLambdaCreateLogGroup"
    actions   = ["logs:CreateLogGroup"]
    resources = ["*"]
  }
  dynamic "statement" {
    for_each = [
      "CreateLogStream",
      "PutLogEvents"
    ]
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
          "log-group:/aws/lambda/${var.prefix}-${var.lambda_function.controller.name}:log-stream:*"
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

resource "aws_iam_role_policy_attachment" "controller_certificate_mgmt_ssm" {
  role       = aws_iam_role.lambda_controller.name
  policy_arn = aws_iam_policy.manage_ca_certificates_ssm.arn
}
resource "aws_iam_role_policy_attachment" "controller_certificate_mgmt_kms" {
  count      = length(aws_iam_policy.manage_ca_certificates_kms) == 0 ? 0 : 1
  role       = aws_iam_role.lambda_controller.name
  policy_arn = aws_iam_policy.manage_ca_certificates_kms[count.index].arn
}
resource "aws_iam_role_policy_attachment" "controller_cloudwatch_mgmt" {
  role       = aws_iam_role.lambda_controller.name
  policy_arn = aws_iam_policy.manage_lambda_controller_cloudwatch.arn
}

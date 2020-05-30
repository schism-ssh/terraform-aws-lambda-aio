data "aws_iam_policy_document" "manage_ca_certificates" {
  statement {
    sid = "ManageCACertificatesSSM"
    actions = [
      "ssm:GetParameter",
      "ssm:PutParameter"
    ]
    resources = [
      "arn:aws:ssm:*:*:parameter/${var.prefix}-${var.ssm.ca_param_prefix}-*"
    ]
  }

  dynamic "statement" {
    for_each = length(var.kms_key.ca_certs.key_id) > 0 ? [var.kms_key.ca_certs.key_id] : []

    content {
      sid = "ManageCACertificatesKMS"
      actions = [
        "kms:Decrypt",
        "kms:Encrypt"
      ]
      resources = ["arn:aws:kms:*:*:key/${statement.value}"]
    }
  }
}
resource "aws_iam_policy" "manage_ca_certificates" {
  name = "${var.prefix}-manage-ca-certificates"

  policy = data.aws_iam_policy_document.manage_ca_certificates.json
}

data "aws_iam_policy_document" "manage_signed_certificates" {
  statement {
    sid = "ManageS3CertObjects"
    actions = [
      "s3:DeleteObject",
      "s3:PutObject",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:HeadBucket",
    ]
    resources = [
      aws_s3_bucket.certificate_storage.arn,
      "${aws_s3_bucket.certificate_storage.arn}/*"
    ]
  }

  statement {
    sid = "ManageCertificatesKMS"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt"
    ]
    resources = [
      "arn:aws:kms:*:${data.aws_caller_identity.current.account_id}:key/*"
    ]
  }
}
resource "aws_iam_policy" "manage_signed_certificates" {
  name = "${var.prefix}-manage-signed-certificates"

  policy = data.aws_iam_policy_document.manage_signed_certificates.json
}

data "aws_iam_policy_document" "manage_lambda_controller_cloudwatch" {
  statement {
    sid = "CloudWatchLambdaCreateLogGroup"
    actions = ["logs:CreateLogGroup"]
    resources = ["*"]
  }
  dynamic "statement" {
    for_each = [
      "CreateLogStream",
      "PutLogEvents"
    ]
    content {
      sid = "CloudWatchLambda${statement.value}"
      actions = ["logs:${statement.value}"]
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
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_controller" {
  name               = "${var.prefix}-${var.lambda_function.controller.name}"
  assume_role_policy = data.aws_iam_policy_document.lambda_controller.json
}

resource "aws_iam_role_policy_attachment" "controller_ca_certificate_mgmt" {
  role       = aws_iam_role.lambda_controller.name
  policy_arn = aws_iam_policy.manage_ca_certificates.arn
}
resource "aws_iam_role_policy_attachment" "controller_signed_certificate_mgmt" {
  role       = aws_iam_role.lambda_controller.name
  policy_arn = aws_iam_policy.manage_signed_certificates.arn
}
resource "aws_iam_role_policy_attachment" "controller_cloudwatch_mgmt" {
  role       = aws_iam_role.lambda_controller.name
  policy_arn = aws_iam_policy.manage_lambda_controller_cloudwatch.arn
}

data "aws_iam_policy_document" "consume_signed_certificates" {
  statement {
    sid = "RetrieveCertificateObjects"
    actions = [
      "s3:ListBucket",
      "s3:HeadBucket",
      "s3:GetObject",
    ]
    resources = [
      aws_s3_bucket.certificate_storage.arn,
      "${aws_s3_bucket.certificate_storage.arn}/*"
    ]
  }
}
resource "aws_iam_policy" "consume_signed_certificates" {
  name = "${var.prefix}-consume-signed-certificates"

  policy = data.aws_iam_policy_document.consume_signed_certificates.json
}

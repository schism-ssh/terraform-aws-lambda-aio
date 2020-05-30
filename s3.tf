resource "aws_s3_bucket" "certificate_storage" {
  bucket = "${var.prefix}-${var.s3_store.name}"

  versioning {
    enabled = var.s3_store.versioned
  }

  dynamic "logging" {
    for_each = var.s3_store.access_logging.enabled ? [var.s3_store.access_logging] : []

    content {
      target_bucket = var.s3_store.access_logging.target_bucket
      target_prefix = "${var.prefix}-${var.s3_store.name}/"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "certificate_storage" {
  bucket                  = aws_s3_bucket.certificate_storage.bucket
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

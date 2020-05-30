output "s3_store" {
  value = {
    certificate_storage = {
      arn    = aws_s3_bucket.certificate_storage.arn
      bucket = aws_s3_bucket.certificate_storage.bucket
      region = aws_s3_bucket.certificate_storage.region
    }
  }
}

# A random suffix keeps the bucket name globally unique across all of AWS.
resource "random_id" "suffix" {
  byte_length = 4
}

# The data lake: input data, job output, cluster logs, and job scripts all
# live under one bucket, separated by key prefixes (folders).
resource "aws_s3_bucket" "data" {
  bucket        = "${var.bucket_base_name}-${random_id.suffix.hex}"
  force_destroy = var.force_destroy_bucket
  tags          = local.common_tags
}

# Keep old object versions so an overwrite never silently loses data.
resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id
  versioning_configuration {
    status = "Enabled"
  }
}

# This bucket is private to your account and cluster — block all public access.
resource "aws_s3_bucket_public_access_block" "data" {
  bucket                  = aws_s3_bucket.data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Expire cluster logs after 30 days so they don't accumulate forever.
resource "aws_s3_bucket_lifecycle_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    id     = "expire-logs"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    expiration {
      days = 30
    }
  }
}

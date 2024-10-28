resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.app}-bucket-${formatdate("YYYYMMDDHHMM", timestamp())}"
  force_destroy = true
  tags = {
    "Application" = var.app
    "Owner"       = var.owner
    "Environment" = var.env
    "CreatedAt"   = timestamp()
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

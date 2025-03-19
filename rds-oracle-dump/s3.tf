resource "aws_s3_bucket" "public_bucket" {
  bucket        = "rds-oracle-backup-2025-03-19-16-00"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_bucket_access_block" {
  bucket                  = aws_s3_bucket.public_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

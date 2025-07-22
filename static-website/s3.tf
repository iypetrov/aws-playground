resource "aws_s3_bucket" "website_bucket" {
  bucket = "ilia-petrov-website-bucket"
}

resource "aws_s3_bucket_ownership_controls" "website_bucket" {
  bucket = aws_s3_bucket.website_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

output "s3_bucket_name" {
  value = aws_s3_bucket.website_bucket.bucket
}

resource "aws_s3_bucket_versioning" "website_versioning" {
  bucket = aws_s3_bucket.website_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "website_bucket" {
  bucket                  = aws_s3_bucket.website_bucket.id
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "website_bucket" {
  depends_on = [
    aws_s3_bucket_ownership_controls.website_bucket,
    aws_s3_bucket_public_access_block.website_bucket,
  ]

  bucket = aws_s3_bucket.website_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.origin_access_identity.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

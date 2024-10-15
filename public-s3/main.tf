resource "aws_s3_bucket" "public_bucket" {
	bucket = "public-s3-2024-10-14-16-23" 
	force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "public_bucket_access_block" {
	bucket = aws_s3_bucket.public_bucket.id
	block_public_acls       = false
	block_public_policy     = false
  	ignore_public_acls      = false
  	restrict_public_buckets = false
}

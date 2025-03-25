resource "aws_s3_bucket" "alb_logs" {
  bucket        = "alb-logs-bucket-202503251012"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket_access_block" {
  bucket                  = aws_s3_bucket.alb_logs.id
  block_public_acls       = true 
  block_public_policy     = true 
  ignore_public_acls      = true 
  restrict_public_buckets = true 
}

resource "aws_s3_bucket_policy" "alb_logs_policy" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSLogDeliveryWrite"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::652711504416:root"
        }
        Action   = "s3:PutObject"
        Resource = "arn:aws:s3:::alb-logs-bucket-202503251012/logs/alb/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

resource "aws_lb" "alb" {
  name                             = "alb"
  internal                         = false
  enable_deletion_protection       = true
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.sg.id]
  subnets                          = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  enable_cross_zone_load_balancing = true
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "logs/alb"
    enabled = true
  }
}

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
        Sid    = "AWSLogDeliveryWrite"
        Effect = "Allow"
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

resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "http"
      from_port        = 80
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 80
    },
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "https"
      from_port        = 443
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = "tcp"
      security_groups  = []
      self             = false
      to_port          = 443
    }
  ]
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "everything"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = -1
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]

  timeouts {
    delete = "2m"
  }
}

resource "aws_lb" "alb" {
  name                             = "alb"
  internal                         = false
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.alb_sg.id]
  subnets                          = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  enable_cross_zone_load_balancing = true
  enable_deletion_protection       = false
  access_logs {
    bucket  = aws_s3_bucket.alb_logs.bucket
    prefix  = "logs/alb"
    enabled = true
  }

  lifecycle {
    replace_triggered_by = [
      aws_security_group.alb_sg,
      aws_security_group.alb_sg.ingress,
      aws_security_group.alb_sg.egress
    ]
  }
}

resource "aws_lb_target_group" "alb_tg" {
  name                 = "alb-tg"
  vpc_id               = aws_vpc.vpc.id
  port                 = "80"
  protocol             = "HTTP"
  target_type          = "ip"
  ip_address_type      = "ipv4"
  deregistration_delay = "10"
  health_check {
    enabled             = "true"
    healthy_threshold   = "3"
    interval            = "30"
    matcher             = "200-399"
    path                = "/200"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "6"
    unhealthy_threshold = "3"
  }
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment_1" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.vm_a.private_ip
  port             = 8080
}

resource "aws_lb_target_group_attachment" "alb_tg_attachment_2" {
  target_group_arn = aws_lb_target_group.alb_tg.arn
  target_id        = aws_instance.vm_b.private_ip
  port             = 8080
}

resource "aws_lb_listener" "alb_listener" {
  load_balancer_arn = aws_lb.alb.arn
  protocol = "HTTP"
  port     = 80
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

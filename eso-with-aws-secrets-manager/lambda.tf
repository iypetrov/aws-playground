resource "aws_iam_role" "lambda_role" {
  name = "secrets-manager-role-${local.env}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "allow-secrets-manager-all-${local.env}"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "secretsmanager:CreateSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:GetSecretValue",
          "secretsmanager:UpdateSecret",
          "secretsmanager:UpdateSecretVersionStage",
          "secretsmanager:DeleteSecret",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecrets",
          "secretsmanager:TagResource",
          "secretsmanager:UntagResource",
          "ssm:GetParameter",
          "ssm:GetParameters",
          "ssm:GetParametersByPath",
          "kms:Decrypt",
          "s3:GetObject",
          "eks:ListClusters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Allow all outbound traffic for Lambda"
  vpc_id            = module.vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lambda_function" "lambda" {
  function_name = "secrets-manager-api-${local.env}"
  timeout       = 900
  image_uri     = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/ener-gxrestricted-infrastructure-secrets-manager-api:1.0.1"
  package_type  = "Image"
  role          = aws_iam_role.lambda_role.arn
  vpc_config {
    subnet_ids                  = module.vpc.private_subnets
    security_group_ids          = [aws_security_group.lambda_sg.id]
  }
  environment {
    variables = {
      APP_ENV = local.env
      S3_BUCKET = aws_s3_bucket.bucket.id
    }
  }
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${local.aws_region}:${data.aws_caller_identity.this.account_id}:${aws_api_gateway_rest_api.api.id}/*/*/*"
}

resource "aws_vpc_endpoint" "eks" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.${local.aws_region}.eks"
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.private_subnets
  security_group_ids = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id            = module.vpc.vpc_id
  service_name      = "com.amazonaws.eu-central-1.secretsmanager"
  vpc_endpoint_type = "Interface"
  subnet_ids        = module.vpc.private_subnets
  security_group_ids = [aws_security_group.lambda_sg.id]
  private_dns_enabled = true
}

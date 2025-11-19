resource "aws_iam_role" "lambda_role" {
  name = "${local.name}-role"
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
  name = "allow-${local.name}-all"
  role = aws_iam_role.lambda_role.id

  # permissions needed for the Lambda function to operate
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "s3:GetObject"
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

resource "aws_lambda_function" "lambda" {
  function_name = "${local.name}"
  timeout       = 900
  image_uri     = "833704146350.dkr.ecr.eu-central-1.amazonaws.com/secrets-manager-api:1.3.0"
  package_type  = "Image"
  role          = aws_iam_role.lambda_role.arn
  vpc_config {
    subnet_ids                  = [aws_subnet.private_subnet_a.id]
    security_group_ids          = [aws_security_group.lambda_sg.id]
  }
  environment {
    variables = {
      APP_ENV = local.env
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

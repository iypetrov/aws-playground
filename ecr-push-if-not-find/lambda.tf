resource "aws_iam_role" "foo_role" {
  name = "foo-role"
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

resource "aws_iam_role_policy_attachment" "foo_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.foo_role.name
}

resource "aws_lambda_function" "foo_function" {
  function_name = "foo-notifier"
  timeout       = 60
  image_uri = "678468774710.dkr.ecr.eu-west-2.amazonaws.com/playground/foo:test"
  package_type  = "Image"
  role          = aws_iam_role.foo_role.arn
  environment {
    variables = {
      APP_ENV = "prod"
    }
  }
}

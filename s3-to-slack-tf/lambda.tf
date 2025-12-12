resource "aws_iam_role" "lambda_role" {
  name = "lambda_sqs_exec_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      },
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "lambda_policy" {
  name = "lambda-all-secrets-access"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl"
        ],
        Resource = aws_sqs_queue.queue.arn
      },
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:GetSecretValue"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_access" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

data "aws_secretsmanager_secret_version" "slack_channel_id" {
  secret_id = "SLACK_CHANNEL_ID"
}

data "aws_secretsmanager_secret_version" "slack_bot_token" {
  secret_id = "SLACK_BOT_TOKEN"
}

resource "aws_lambda_function" "lambda" {
  function_name = "queue-event-to-slack"
  timeout       = 900
  image_uri     = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/queue-event-to-slack:1.2.2"
  package_type  = "Image"
  role          = aws_iam_role.lambda_role.arn
  environment {
    variables = {
      APP_ENV   = local.env
      SLACK_CHANNEL_ID_ARN = data.aws_secretsmanager_secret_version.slack_channel_id.arn
      SLACK_BOT_TOKEN_ARN  = data.aws_secretsmanager_secret_version.slack_bot_token.arn
    }
  }
}

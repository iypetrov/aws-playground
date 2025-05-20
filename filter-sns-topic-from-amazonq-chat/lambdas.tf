resource "aws_iam_role" "filter_sns_topic_from_amazonq_chat_function_role" {
  name = "filter-sns-topic-from-amazonq-chat-function-role"
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

resource "aws_iam_role_policy_attachment" "filter_sns_topic_from_amazonq_chat_function_vpc_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
  role       = aws_iam_role.filter_sns_topic_from_amazonq_chat_function_role.name
}

resource "aws_lambda_function" "filter_sns_topic_from_amazonq_chat_function" {
  function_name = "filter-sns-topic-from-amazonq-chat"
  timeout       = 900
  image_uri     = "678468774710.dkr.ecr.eu-west-2.amazonaws.com/filter-sns-topic-from-amazonq-chat:1.2.0"
  package_type  = "Image"
  role          = aws_iam_role.filter_sns_topic_from_amazonq_chat_function_role.arn
  environment {
    variables = {
      APP_ENV = "prod"
      AWS_TARGET_SNS_TOPIC_ARN = aws_sns_topic.alb_notifications.arn
    }
  }
}

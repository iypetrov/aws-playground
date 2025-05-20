resource "aws_sns_topic" "raw_alb_notifications" {
  name = "raw-alb-notifications"
}

resource "aws_lambda_permission" "allow_sns_invoke_lambda" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.filter_sns_topic_from_amazonq_chat_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.raw_alb_notifications.arn
}

resource "aws_sns_topic_subscription" "lambda_sub" {
  topic_arn = aws_sns_topic.raw_alb_notifications.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.filter_sns_topic_from_amazonq_chat_function.arn
}

resource "aws_sns_topic" "alb_notifications" {
  name = "alb-notifications"
}

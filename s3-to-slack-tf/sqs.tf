resource "aws_sqs_queue" "queue" {
  name = "s3-to-slack-queue"
  visibility_timeout_seconds = 6 * aws_lambda_function.lambda.timeout
}

resource "aws_sqs_queue_policy" "s3_events_policy" {
  queue_url = aws_sqs_queue.queue.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "s3.amazonaws.com"
      }
      Action   = "sqs:SendMessage"
      Resource = aws_sqs_queue.queue.arn
      Condition = {
        ArnEquals = {
          "aws:SourceArn" = aws_s3_bucket.bucket.arn
        }
      }
    }]
  })
}

resource "aws_lambda_event_source_mapping" "sqs_to_lambda" {
  event_source_arn = aws_sqs_queue.queue.arn
  function_name    = aws_lambda_function.lambda.arn
  batch_size       = 10
  enabled          = true
}

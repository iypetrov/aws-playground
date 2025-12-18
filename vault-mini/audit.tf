resource "aws_cloudwatch_event_rule" "audit" {
  name        = "capture-aws-secrets-manager-api-audit-${local.env}"
  description = "Capture each AWS Secrets Manager API call via CloudTrail for auditing purposes"
  event_pattern = jsonencode({
    source = [
      "aws.secretsmanager"
    ]
    detail-type = [
      "AWS API Call via CloudTrail"
    ]
    detail = {
        eventSource = [
          "secretsmanager.amazonaws.com"
        ]
        eventName = [
          "CreateSecret",
          "PutSecretValue",
          "DeleteSecret"
        ]
    }
  })
}

resource "aws_iam_role" "lambda_audit_role" {
  name = "auto-acm-import-from-secrets-manager-role"
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

resource "aws_iam_role_policy" "lambda_audit_policy" {
  name = "auto-acm-import-from-secrets-manager-policy"
  role = aws_iam_role.lambda_audit_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "secretsmanager:DescribeSecret",
          "dynamodb:PutItem"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_audit_logging" {
  role       = aws_iam_role.lambda_audit_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "lambda_audit" {
  function_name = "auto-acm-import-from-secrets-manager"
  timeout       = 900
  image_uri     = "${data.aws_caller_identity.this.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/auto-acm-import-from-secrets-manager:1.4.0"
  package_type  = "Image"
  role          = aws_iam_role.lambda_audit_role.arn
  environment {
    variables = {
      APP_ENV   = local.env
    }
  }
}

resource "aws_cloudwatch_event_target" "audit_target" {
  target_id = "SendToAuditLambda"
  rule      = aws_cloudwatch_event_rule.audit.name
  arn       = aws_lambda_function.lambda_audit.arn
}

resource "aws_lambda_permission" "audit_target_permission" {
    statement_id = "AllowExecutionFromCloudWatch"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.lambda_audit.function_name}"
    principal = "events.amazonaws.com"
    source_arn = "${aws_cloudwatch_event_rule.audit.arn}"
}

resource "aws_dynamodb_table" "audit_tls_events" {
  name         = "audit-tls-events"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  ttl {
    attribute_name = "expire_at"
    enabled        = true
  }
}

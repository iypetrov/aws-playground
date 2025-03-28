resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_instances_alarm" {
  alarm_name                = "alb-unhealthy-instaces-alarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = 1
  metric_name               = "UnHealthyHostCount"
  namespace                 = "AWS/ApplicationELB"
  period                    = 60
  statistic                 = "Maximum"
  threshold                 = 1
  actions_enabled           = true
  alarm_description         = "Alarm when the number of unhealthy instances is greater than or equal to 1"
  insufficient_data_actions = []
  alarm_actions = [
    aws_sns_topic.alb_notifications.arn
  ]
  ok_actions = [
    aws_sns_topic.alb_notifications.arn
  ]
  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
    TargetGroup  = aws_lb_target_group.alb_tg.arn_suffix
  }
}

resource "aws_sns_topic" "alb_notifications" {
  name = "alb-notifications"
}

resource "aws_iam_role" "chatbot_role" {
  name = "chatbot-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect    = "Allow",
        Principal = { Service = "chatbot.amazonaws.com" },
        Action    = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "chatbot_policy" {
  name = "chatbot-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "sns:Publish"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "chatbot_policy_attachment" {
  role       = aws_iam_role.chatbot_role.name
  policy_arn = aws_iam_policy.chatbot_policy.arn
}

# should enable it from the ui :(
# https://teams.microsoft.com/l/channel/<teams_channel_id>/<team_channel_name>?groupId=<team_id>&tenantId=<teams_tennant_id>
resource "awscc_chatbot_microsoft_teams_channel_configuration" "teams_chatbot" {
  configuration_name = "teams-chatbot"
  iam_role_arn       = aws_iam_role.chatbot_role.arn
  team_id            = "team_id"
  teams_channel_id   = "teams_channel_id"
  teams_tenant_id    = "teams_tenant_id"
  logging_level      = "INFO"
  sns_topic_arns = [
    aws_sns_topic.alb_notifications.arn
  ]
}

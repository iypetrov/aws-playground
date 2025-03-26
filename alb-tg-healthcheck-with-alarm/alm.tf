resource "aws_cloudwatch_metric_alarm" "alb_unhealthy_instances_alarm" {
  alarm_name          = "alb-unhealthy-instaces-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.alb_notifications.arn]
  alarm_description   = "Alarm when the number of unhealthy instances is greater than or equal to 1"
  dimensions = {
    LoadBalancer = aws_lb.alb.name
    TargetGroup  = aws_lb_target_group.alb_tg.name
  }
  insufficient_data_actions = []
}

resource "aws_sns_topic" "alb_notifications" {
  name = "alb-notifications"
}

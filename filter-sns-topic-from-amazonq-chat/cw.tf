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
    aws_sns_topic.raw_alb_notifications.arn
  ]
  ok_actions = [
    aws_sns_topic.raw_alb_notifications.arn
  ]
  dimensions = {
    LoadBalancer = aws_lb.alb.arn_suffix
    TargetGroup  = aws_lb_target_group.alb_tg.arn_suffix
  }
}

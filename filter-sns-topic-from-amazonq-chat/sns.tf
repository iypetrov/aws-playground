resource "aws_sns_topic" "raw_alb_notifications" {
  name = "raw-alb-notifications"
}

resource "aws_sns_topic" "alb_notifications" {
  name = "alb-notifications"
}

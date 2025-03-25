resource "aws_security_group" "asg_sg" {
  vpc_id = aws_vpc.vpc.id
  ingress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "everything"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = -1
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
  egress = [
    {
      cidr_blocks      = ["0.0.0.0/0"]
      description      = "everything"
      from_port        = 0
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      protocol         = -1
      security_groups  = []
      self             = false
      to_port          = 0
    }
  ]
}

resource "aws_iam_role" "asg_role" {
  name = "ec2-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "asg_policy" {
  name = "asg-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "*"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "asg_policy_attachment" {
  role       = aws_iam_role.asg_role.name
  policy_arn = aws_iam_policy.asg_policy.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2-profile"
  role = aws_iam_role.asg_role.name
}

resource "aws_launch_template" "asg_lt" {
  name_prefix            = "asg-lt-"
  image_id               = "ami-07c1b39b7b3d2525d"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.asg_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  monitoring {
    enabled = true
  }
  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Dependencies
    echo "Updating and installing dependencies starts"
    apt-get update -y
    apt-get install -y tmux vim curl
    echo "Updating and installing dependencies ends"

    # Docker
    echo "Installing Docker starts"
    curl -fsSl https://get.docker.com | sh
    gpasswd -a ubuntu docker
    echo "Installing Docker ends"

    # Run docker app 
    echo "Running the docker app starts"
    docker run -it --rm -p 8080:8080 --network host iypetrov/debug-display-req-headers:1.2.0
    echo "Running the docker app ends"
  EOF
  )
}

resource "aws_autoscaling_group" "asg" {
  launch_template {
    id      = aws_launch_template.asg_lt.id
    version = aws_launch_template.asg_lt.latest_version
  }
  name                      = "asg"
  desired_capacity          = 2
  max_size                  = 3
  min_size                  = 1
  vpc_zone_identifier       = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  force_delete              = true
  wait_for_capacity_timeout = "0"
  health_check_type         = "EC2"
  health_check_grace_period = 60
  termination_policies      = ["OldestInstance"]
  enabled_metrics           = ["GroupInServiceInstances"]
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage       = 100
      scale_in_protected_instances = "Refresh"
    }
  }
}

resource "aws_autoscaling_policy" "asg_scale_in_policy" {
  name                   = "asg-scale-in-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  enabled                = true
  cooldown               = 60
  scaling_adjustment     = -1
}

resource "aws_autoscaling_policy" "asg_scale_out_policy" {
  name                   = "asg-scale-out-policy"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "SimpleScaling"
  enabled                = true
  cooldown               = 60
  scaling_adjustment     = 1
}

resource "aws_cloudwatch_metric_alarm" "asg_high_cpu_alarm" {
  alarm_name          = "asg-high-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.asg_scale_out_policy.arn]
  alarm_description   = "Alarm when CPU exceeds 75%"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  insufficient_data_actions = []
}

resource "aws_cloudwatch_metric_alarm" "asg_two_instances_alarm" {
  alarm_name          = "asg-two-instances-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "GroupInServiceInstances"
  namespace           = "AWS/AutoScaling"
  period              = 60
  statistic           = "Average"
  threshold           = 3
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.asg_scale_in_policy.arn]
  alarm_description   = "Triggers when the ASG has 3 instances"
  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.asg.name
  }
  insufficient_data_actions = []
}

# 1. AWS Provider
provider "aws" {
  region = "us-west-2"  # Update with your desired region
}

# 2. EC2 Instance with IAM Role for CloudWatch
resource "aws_instance" "ec2_instance" {
  ami           = "ami-00c257e12d6828491"  # Example: Ubuntu 20.04 LTS AMI
  instance_type = "t2.micro"
  key_name      = "annis"  # Replace with your key pair

  iam_instance_profile = aws_iam_instance_profile.cloudwatch_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get install -y awscli
              apt-get install -y amazon-cloudwatch-agent
              echo '{
                "metrics": {
                  "namespace": "CustomMetrics",
                  "metrics_collected": {
                    "cpu": {
                      "measurement": ["cpu_usage_idle"],
                      "metrics_collection_interval": 60
                    }
                  }
                }
              }' > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop
              /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start
            EOF

  tags = {
    Name = "CloudWatch-Metrics-EC2-Monitoring"
  }

  vpc_security_group_ids = [
    aws_security_group.sg.id,
  ]
}

resource "aws_security_group" "sg" {
  name        = "ec2-ssh"
  description = "Allow SSH inbound traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 3. IAM Role for EC2 to publish custom metrics
resource "aws_iam_role" "cloudwatch_role" {
  name = "CloudWatchCustomMetricsRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}

resource "aws_iam_policy" "cloudwatch_policy" {
  name        = "CloudWatchCustomMetricsPolicy"
  description = "Policy to allow EC2 to send custom metrics to CloudWatch"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "cloudwatch:PutMetricData"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy_attachment" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudwatch_policy.arn
}

# 4. IAM Instance Profile to attach role to EC2 instance
resource "aws_iam_instance_profile" "cloudwatch_instance_profile" {
  name = "CloudWatchInstanceProfile"
  role = aws_iam_role.cloudwatch_role.name
}

# 5. CloudWatch Alarm for CPU Usage
resource "aws_cloudwatch_metric_alarm" "cpu_custom_alarm" {
  alarm_name          = "HighCPUUsageAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "cpu_usage_idle"
  namespace           = "CustomMetrics"
  period              = "60"
  statistic           = "Average"
  threshold           = "90"
  alarm_description   = "This alarm will trigger if CPU usage exceeds 90%."

  dimensions = {
    InstanceId = aws_instance.ec2_instance.id
  }

  alarm_actions = [
    aws_sns_topic.alert_topic.arn
  ]
}

# 6. SNS Topic for Alarm Notifications
resource "aws_sns_topic" "alert_topic" {
  name = "cloudwatch-alerts"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.alert_topic.arn
  protocol  = "email"
  endpoint  = "muralimupparaju@gmail.com"  # Replace with your email address
}

#### iam policies and permissions block
data "aws_iam_policy_document" "ec2_start_stop_scheduler" {
  statement {

      actions = [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ]

      resources = [
        "arn:aws:logs:*:*:*",
      ]

    }

  statement {

      actions = [
        "ec2:Describe*",
        "ec2:Stop*",
        "ec2:Start*"
      ]

      resources = [
          "*",
      ]
    }
}

resource "aws_iam_policy" "ec2_start_stop_scheduler" {
  name = "ec2_access_scheduler"
  path = "/"
  policy = "${data.aws_iam_policy_document.ec2_start_stop_scheduler.json}"
}

resource "aws_iam_role_policy_attachment" "ec2_access_scheduler" {
  role       = "${aws_iam_role.start_stop_role.name}"
  policy_arn = "${aws_iam_policy.ec2_start_stop_scheduler.arn}"
}

resource "aws_iam_role" "start_stop_role" {
  name = "start-stop-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    },
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "scheduler.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}
#### End of iam policies and permissions block


#   # Attach the necessary policies
#   managed_policy_arns = [
#     "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM",
#     "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
#   ]
# }

#### scheduler block
resource "aws_scheduler_schedule" "scheduler_on" {
  name       = "scheduler-on"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  # Run it at 7 AM every day utc = 4
  schedule_expression = "cron(0 4 ? * * *)"

  target {
    # This indicates that the event should be sent to the EC2 API and the startInstances action should be triggered
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:startInstances"
    role_arn = aws_iam_role.start_stop_role.arn

    # Pass the instance ID as input
    input = jsonencode({
      InstanceIds = [
        aws_instance.terra_ec2.id
      ]
    })
  }
}

resource "aws_scheduler_schedule" "scheduler_off" {
  name       = "scheduler-off"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  # Run it at 7 PM every day, off utc = 16
  schedule_expression = "cron(0 16 ? * * *)"

  target {
    # This indicates that the event should be sent to the EC2 API and the stopInstances action should be triggered
    arn      = "arn:aws:scheduler:::aws-sdk:ec2:stopInstances"
    role_arn = aws_iam_role.start_stop_role.arn

    # Pass the instance ID as input
    input = jsonencode({
      InstanceIds = [
        aws_instance.terra_ec2.id
      ]
    })
  }
}
###### end of scheduler block

# Create SNS Topic
resource "aws_sns_topic" "ec2_state_change_topic" {
  name = "EC2StateChangeTopic"
}

# Create SNS Topic Subscription
# resource "aws_sns_topic_subscription" "ec2_state_change_subscription" {
#   topic_arn = aws_sns_topic.ec2_state_change_topic.arn
#   protocol  = "email"
#   endpoint  = local.email
# }
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.ec2_state_change_topic.arn
  protocol  = "sms"
  endpoint  = local.tel
}


# Create CloudWatch Event Rule
resource "aws_cloudwatch_event_rule" "ec2_state_change_rule" {
  name        = "EC2StateChangeRule"
  description = "Rule to track EC2 instance state changes"
  event_pattern = <<PATTERN
{
  "source": ["aws.ec2"],
  "detail-type": ["EC2 Instance State-change Notification"],
  "detail": {
    "state": ["running", "stopped"]
  }
}
PATTERN
}

# Create IAM Role for CloudWatch Events to publish to SNS
resource "aws_iam_role" "cloudwatch_to_sns_role" {
  name = "CloudWatchToSNSRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach IAM policy to the CloudWatch to SNS role
resource "aws_iam_role_policy_attachment" "cloudwatch_to_sns_policy_attachment" {
  role       = aws_iam_role.cloudwatch_to_sns_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchEventsFullAccess"
}

# Create IAM Role for SNS to publish to CloudWatch Events
resource "aws_iam_role" "sns_to_cloudwatch_role" {
  name = "SNSToCloudWatchRole"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "sns.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

# Attach IAM policy to the SNS to CloudWatch role
resource "aws_iam_role_policy_attachment" "sns_to_cloudwatch_policy_attachment" {
  role       = aws_iam_role.sns_to_cloudwatch_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# Add permissions to allow CloudWatch Events to publish to SNS
resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = aws_sns_topic.ec2_state_change_topic.arn

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "events.amazonaws.com"
      },
      "Action": "sns:Publish",
      "Resource": "${aws_sns_topic.ec2_state_change_topic.arn}"
    }
  ]
}
POLICY
}

# Create EventBridge rule target to publish to SNS
resource "aws_cloudwatch_event_target" "sns_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change_rule.name
  target_id = "EC2StateChangeSnsTarget"
  arn       = aws_sns_topic.ec2_state_change_topic.arn

}


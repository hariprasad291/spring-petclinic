resource "aws_iam_role" "iam_for_lambda" {
  name = "${var.lambda_name}-role-${var.env}"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
    "Action": "sts:AssumeRole",
    "Effect": "Allow",
      "Sid": "",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    }
  }]
}
EOF
   tags = merge(local.tags,{
    resource-type = "iam-role",
    name = "${var.lambda_name}-role-${var.env}"
  })
}
resource "aws_iam_role_policy_attachment" "lambda-executioner-policy-attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

 #Please change this with your Lambda Function name and description 
resource "aws_iam_policy" "receive-hep-events-ec2-policy" { 
  name        = "${var.lambda_name}-ec2-policy" 
  description = "Retrieve Items from DynamoDB"

  policy = <<EOF
{
"Version": "2012-10-17",
"Statement": [
  {
    "Effect": "Allow",
    "Action": [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface"
    ],
    "Resource": "*"
  }
]
}
EOF
}
#Change the ec2 policy arn 
resource "aws_iam_role_policy_attachment" "receive-hep-events-ec2-policy-attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.receive-hep-events-ec2-policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

resource "aws_iam_policy" "lambda-sns-policy" {
  name        = "${var.lambda_name}-sns-policy"
  description = "Publish SNS messages"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid":"AllowPublishToMyTopic",
            "Effect":"Allow",
            "Action":["sns:Publish",
                      "sns:AddPermission",
                      "sns:GetTopicAttributes",
                      "sns:ListSubscriptionsByTopic",
                      "sns:SetTopicAttributes"
            ],
            "Resource": ["${data.aws_ssm_parameter.sns_arn_encounter_insurance_updated_topic.value}","${var.sns_topic_app_confirm_arn}"]
        }
    ]
}
EOF
}
resource "aws_iam_role_policy_attachment" "lambda-sns-policy-attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda-sns-policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_sqs_policy.arn
}
resource "aws_iam_policy" "lambda_sqs_policy" {
  name        = "${var.lambda_name}-sqs-policy"
  description = "Post messages in  SQS"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:SendMessage",
                "sqs:GetQueueAttributes",
                "sqs:GetQueueUrl"
            ],
            "Resource": ["${var.sqs_arn_patient_ehr_message_queue}", "${data.aws_ssm_parameter.sqs_arn_appointment_reminder_notification_queue.value}"]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_eventbridge_policy_attachment" {
  role = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_eventbridge_policy.arn
}

resource "aws_iam_policy" "lambda_eventbridge_policy" {
  name        = "${var.lambda_name}-eventbrdige-policy"
  description = "Post messages in  Event Bridge"

  policy = <<EOF
{
    "Version": "2025-06-12",
    "Statement": [
        {
            "Sid": "AllowEventBridgeActions",
            "Effect": "Allow",
            "Action": [
                "events:PutEvents"
            ],
            "Resource": ["${var.eventbridge_arn_app_notification_topic}","${var.eventbridge_app_notification_arn}"]
        }
    ]
}
EOF
}
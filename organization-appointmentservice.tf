module "organization-appointmentservice-application" {
  source = "./modules/elb-documentdb-application"

  application_name    = "organizationappointmentservice"
  environment         = var.environment
  docdb_instance_type = "db.t3.medium"
  instance_type       = "t2.micro"
  public_subnets      = module.vpc.public_subnets
  private_subnets     = module.vpc.private_subnets
  vpc_id              = module.vpc.vpc_id
  region              = var.region
  aws_access_key      = var.aws_access_key
  aws_secret_key      = var.aws_secret_key
}

#####################
# Appointment Queue #
#####################
resource "aws_sqs_queue" "appointment-queue" {
  name                       = "appointment-queue"
  visibility_timeout_seconds = 300

  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "appointment_sqs_target" {
  topic_arn = aws_sns_topic.appointment-changed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.appointment-queue.arn
}

resource "aws_sqs_queue_policy" "appointment_queue_policy" {
  queue_url = aws_sqs_queue.appointment-queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.appointment-queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.appointment-changed.arn}"
        }
      }
    }
  ]
}
POLICY
}

#################
# Service Queue #
#################
resource "aws_sqs_queue" "service-queue" {
  name                       = "service-queue"
  visibility_timeout_seconds = 300

  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "service_sqs_target" {
  topic_arn = aws_sns_topic.service-changed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.service-queue.arn
}

resource "aws_sqs_queue_policy" "service_queue_policy" {
  queue_url = aws_sqs_queue.service-queue.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "First",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.service-queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.service-changed.arn}"
        }
      }
    }
  ]
}
POLICY
}

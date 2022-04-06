module "organization-appointmentservice-application" {
  source = "./modules/elb-documentdb-application"

  application_name    = "organizationappointmentservice"
  s3_bucket_id        = var.s3_bucket_id
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

###############
# API_Gateway #
###############
resource "aws_api_gateway_resource" "organizationappointment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.service.id
  path_part   = "organizationappointment"
}

resource "aws_api_gateway_resource" "organizationappointment_api" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organizationappointment.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "organizationappointment_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organizationappointment_api.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "organizationappointment_any" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organizationappointment_proxy.id
  http_method        = "ANY"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organizationappointment_any_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organizationappointment_proxy.id
  http_method             = aws_api_gateway_method.organizationappointment_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organization-appointmentservice-application.elb_endpoint_url}/api/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "organizationappointment_slots" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organizationappointment_api.id
  path_part   = "slots"
}

resource "aws_api_gateway_method" "organizationappointment_slots" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organizationappointment_slots.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organizationappointment_slots_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organizationappointment_proxy.id
  http_method             = aws_api_gateway_method.organizationappointment_slots.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organization-appointmentservice-application.elb_endpoint_url}/api/slots"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "organizationappointment_appointments" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organizationappointment_api.id
  path_part   = "appointments"
}

resource "aws_api_gateway_method" "organizationappointment_appointments_delete" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organizationappointment_appointments.id
  http_method        = "DELETE"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organizationappointment_appointments_delete_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organizationappointment_appointments.id
  http_method             = aws_api_gateway_method.organizationappointment_appointments_delete.http_method
  integration_http_method = "DELETE"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.appointmentservice-application.elb_endpoint_url}/api/appointments"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
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

#################
# Closing Time Queue #
#################
resource "aws_sqs_queue" "closing-time-queue" {
  name                       = "closing-time-queue"
  visibility_timeout_seconds = 300

  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "closing_time_sqs_target" {
  topic_arn = aws_sns_topic.closing-time-changed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.closing-time-queue.arn
}

resource "aws_sqs_queue_policy" "closing_time_queue_policy" {
  queue_url = aws_sqs_queue.closing-time-queue.id

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
      "Resource": "${aws_sqs_queue.closing-time-queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.closing-time-changed.arn}"
        }
      }
    }
  ]
}
POLICY
}

#################
# Opening Hour Queue #
#################
resource "aws_sqs_queue" "opening-hour-queue" {
  name                       = "opening-hour-queue"
  visibility_timeout_seconds = 300

  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "opening-hour_sqs_target" {
  topic_arn = aws_sns_topic.opening-hour-changed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.opening-hour-queue.arn
}

resource "aws_sqs_queue_policy" "opening-hour_queue_policy" {
  queue_url = aws_sqs_queue.opening-hour-queue.id

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
      "Resource": "${aws_sqs_queue.opening-hour-queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.opening-hour-changed.arn}"
        }
      }
    }
  ]
}
POLICY
}

#################
# Working Hour Queue #
#################
resource "aws_sqs_queue" "working-hour-queue" {
  name                       = "working-hour-queue"
  visibility_timeout_seconds = 300

  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "working-hour_sqs_target" {
  topic_arn = aws_sns_topic.working-hour-changed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.working-hour-queue.arn
}

resource "aws_sqs_queue_policy" "working-hour_queue_policy" {
  queue_url = aws_sqs_queue.working-hour-queue.id

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
      "Resource": "${aws_sqs_queue.working-hour-queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.working-hour-changed.arn}"
        }
      }
    }
  ]
}
POLICY
}

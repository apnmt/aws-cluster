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

resource "aws_api_gateway_resource" "organizationappointment_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organizationappointment.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "organizationappointment_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organizationappointment_api_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "organizationappointment_get" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organizationappointment_proxy.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "organizationappointment_post" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organizationappointment_proxy.id
  http_method        = "POST"
  authorization      = "COGNITO_USER_POOLS"
  authorizer_id      = aws_api_gateway_authorizer.api_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organizationappointment_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organizationappointment_proxy.id
  http_method             = aws_api_gateway_method.organizationappointment_get.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.appointmentservice-application.elb_endpoint_url}/api/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration" "organizationappointment_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organizationappointment_proxy.id
  http_method             = aws_api_gateway_method.organizationappointment_post.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.appointmentservice-application.elb_endpoint_url}/api/{proxy}"

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

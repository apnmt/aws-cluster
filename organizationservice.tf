module "organizationservice-application" {
  source = "./modules/elb-postgres-application"

  application_name = "organizationservice"
  s3_bucket_id     = var.s3_bucket_id
  environment      = var.environment
  db_instance_type = "db.t2.micro"
  instance_type    = "t2.micro"
  public_subnets   = module.vpc.public_subnets
  private_subnets  = module.vpc.private_subnets
  vpc_id           = module.vpc.vpc_id
  region           = var.region
  aws_access_key   = var.aws_access_key
  aws_secret_key   = var.aws_secret_key
}

###############
# API_Gateway #
###############
resource "aws_api_gateway_resource" "organization" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.service.id
  path_part   = "organization"
}

resource "aws_api_gateway_resource" "organization_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "organization_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_api_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "organization_get" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_proxy.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "organization_post" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_proxy.id
  http_method        = "POST"
  authorization      = "COGNITO_USER_POOLS"
  authorizer_id      = aws_api_gateway_authorizer.api_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organization_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_proxy.id
  http_method             = aws_api_gateway_method.organization_get.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration" "organization_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_proxy.id
  http_method             = aws_api_gateway_method.organization_post.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}


#################
# Organization Activation Queue #
#################
resource "aws_sqs_queue" "organization-activation-queue" {
  name                       = "service-queue"
  visibility_timeout_seconds = 300

  tags = {
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "organization-activation_sqs_target" {
  topic_arn = aws_sns_topic.organization-activation-changed.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.organization-activation-queue.arn
}

resource "aws_sqs_queue_policy" "organization-activation_queue_policy" {
  queue_url = aws_sqs_queue.organization-activation-queue.id

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
      "Resource": "${aws_sqs_queue.organization-activation-queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.organization-activation-changed.arn}"
        }
      }
    }
  ]
}
POLICY
}
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

resource "aws_api_gateway_resource" "organizations" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_api_resource.id
  path_part   = "organizations"
}

resource "aws_api_gateway_resource" "organizations_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organizations.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "organization_any" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_proxy.id
  http_method        = "ANY"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "organizations_get" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organizations.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "organization_get" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organizations_proxy.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organization_any_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_proxy.id
  http_method             = aws_api_gateway_method.organization_any.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration" "organizations_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organizations.id
  http_method             = aws_api_gateway_method.organizations_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/organizations"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration" "organization_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organizations_proxy.id
  http_method             = aws_api_gateway_method.organization_get.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/organizations/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "organization_opening_hours" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_api_resource.id
  path_part   = "opening-hours"
}

resource "aws_api_gateway_method" "organization_opening_hours_post" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_opening_hours.id
  http_method        = "POST"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organization_opening_hours_integration_post" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_opening_hours.id
  http_method             = aws_api_gateway_method.organization_opening_hours_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/opening-hours"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "organization_opening_hours_organization" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_opening_hours.id
  path_part   = "organization"
}

resource "aws_api_gateway_resource" "organization_opening_hours_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_opening_hours_organization.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "organization_opening_hours" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_opening_hours_proxy.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organization_opening_hours_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_opening_hours_proxy.id
  http_method             = aws_api_gateway_method.organization_opening_hours.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/opening-hours/organization/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "organization_working_hours" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_api_resource.id
  path_part   = "working-hours"
}

resource "aws_api_gateway_method" "organization_working_hours_post" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_working_hours.id
  http_method        = "POST"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organization_working_hours_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_working_hours.id
  http_method             = aws_api_gateway_method.organization_working_hours_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/working-hours"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "organization_working_hours_organization" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_working_hours.id
  path_part   = "organization"
}

resource "aws_api_gateway_resource" "organization_working_hours_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_working_hours_organization.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "organization_working_hours" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_working_hours_proxy.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organization_working_hours_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_working_hours_proxy.id
  http_method             = aws_api_gateway_method.organization_working_hours.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/working-hours/organization/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "organization_closing_times" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_api_resource.id
  path_part   = "closing-times"
}

resource "aws_api_gateway_resource" "organization_closing_times_organization" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_closing_times.id
  path_part   = "organization"
}

resource "aws_api_gateway_resource" "organization_closing_times_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_closing_times_organization.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "organization_closing_times" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_closing_times_proxy.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organization_closing_times_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_closing_times_proxy.id
  http_method             = aws_api_gateway_method.organization_closing_times.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/closing-times/organization/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "organization_employees" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_api_resource.id
  path_part   = "employees"
}

resource "aws_api_gateway_method" "organization_employees_post" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_employees.id
  http_method        = "POST"
  authorization      = "CUSTOM"
  authorizer_id      = aws_api_gateway_authorizer.authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organization_employees_integration_post" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_employees.id
  http_method             = aws_api_gateway_method.organization_employees_post.http_method
  integration_http_method = "POST"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/employees"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_resource" "organization_employees_organization" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_employees.id
  path_part   = "organization"
}

resource "aws_api_gateway_resource" "organization_employees_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.organization_employees_organization.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "organization_employees" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.organization_employees_proxy.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "organization_employees_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.organization_employees_proxy.id
  http_method             = aws_api_gateway_method.organization_employees.http_method
  integration_http_method = "GET"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.organizationservice-application.elb_endpoint_url}/api/employees/organization/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

#################
# Organization Activation Queue #
#################
resource "aws_sqs_queue" "organization-activation-queue" {
  name                       = "organization-activation-queue"
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
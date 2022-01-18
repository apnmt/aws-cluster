module "appointmentservice-application" {
  source = "./modules/elb-postgres-application"

  application_name = "appointmentservice"
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
resource "aws_api_gateway_resource" "appointment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.service.id
  path_part   = "appointment"
}

resource "aws_api_gateway_resource" "appointment_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.appointment.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "appointment_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.appointment_api_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "appointment_get" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.appointment_proxy.id
  http_method        = "GET"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_method" "appointment_post" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.appointment_proxy.id
  http_method        = "POST"
  authorization      = "COGNITO_USER_POOLS"
  authorizer_id      = aws_api_gateway_authorizer.api_authorizer.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "appointment_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.appointment_proxy.id
  http_method             = aws_api_gateway_method.appointment_get.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.appointmentservice-application.elb_endpoint_url}/api/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}

resource "aws_api_gateway_integration" "appointment_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.appointment_proxy.id
  http_method             = aws_api_gateway_method.appointment_post.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.appointmentservice-application.elb_endpoint_url}/api/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
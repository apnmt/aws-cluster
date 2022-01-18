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

resource "aws_api_gateway_resource" "appointment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.service.id
  path_part   = "appointment"
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.appointment.id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "get_appointments" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.proxy.id
  http_method        = "ANY"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.proxy.id
  http_method             = aws_api_gateway_method.get_appointments.http_method
  integration_http_method = "ANY"
  type                    = "HTTP_PROXY"
  uri                     = "http://${module.appointmentservice-application.elb_endpoint_url}/api/{proxy}"

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
module "paymentservice-application" {
  source = "./modules/lambda-application"

  application_name = "paymentservice"
  handler          = "de.apnmt.payment.LambdaHandler::handleRequest"
  s3_bucket_id     = var.s3_bucket_id
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
resource "aws_api_gateway_resource" "payment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.service.id
  path_part   = "appointment"
}

resource "aws_api_gateway_resource" "appointment_proxy" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.payment.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "payment_any" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.appointment_proxy.id
  http_method        = "ANY"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "appointment_get_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.appointment_proxy.id
  http_method             = aws_api_gateway_method.payment_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.paymentservice-application.invoke_arn

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
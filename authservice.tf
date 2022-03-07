module "authservice-application" {
  source = "./modules/lambda-application"

  application_name      = "authservice"
  handler               = "authservice.handler"
  s3_bucket_id          = var.s3_bucket_id
  public_subnets        = module.vpc.public_subnets
  private_subnets       = module.vpc.private_subnets
  vpc_id                = module.vpc.vpc_id
  region                = var.region
  runtime               = "nodejs14.x"
  environment_variables = {
    ACCESS_KEY           = var.aws_access_key,
    SECRET_KEY           = var.aws_secret_key,
    COGNITO_USER_POOL_ID = aws_cognito_user_pool.apnmt_user_pool.id
  }
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.authservice-application.function_name
  principal     = "apigateway.amazonaws.com"

  # The "/*/*" portion grants access from any method on any resource
  # within the API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

###############
# API_Gateway #
###############
resource "aws_api_gateway_resource" "authentication" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.service.id
  path_part   = "authentication"
}

resource "aws_api_gateway_resource" "appointment_registration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_resource.authentication.id
  path_part   = "registration"
}

resource "aws_api_gateway_method" "authentication_any" {
  rest_api_id        = aws_api_gateway_rest_api.api.id
  resource_id        = aws_api_gateway_resource.appointment_registration.id
  http_method        = "POST"
  authorization      = "NONE"
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "authentication_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.appointment_registration.id
  http_method             = aws_api_gateway_method.authentication_any.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.authservice-application.invoke_arn

  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
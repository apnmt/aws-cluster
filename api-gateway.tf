resource "aws_api_gateway_rest_api" "api" {
  name        = "api-gateway"
  description = "Proxy to handle requests to our Services"

  tags = {
    ResourceGroup = "apnmt-aws"
  }
}

resource "aws_api_gateway_resource" "service" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "service"
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  triggers    = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_integration.appointment_any_integration.id,
      aws_api_gateway_integration.appointment_appointments_get_integration.id,
      aws_api_gateway_integration.appointment_appointments_post_integration.id,
      aws_api_gateway_integration.appointment_appointments_put_integration.id,
      aws_api_gateway_integration.appointment_appointment_delete_integration.id,
      aws_api_gateway_integration.appointment_customers_any_integration.id,
      aws_api_gateway_integration.appointment_services_get_integration.id,
      aws_api_gateway_integration.appointment_services_post_integration.id,
      aws_api_gateway_integration.appointment_appointments_delete_integration.id,
      aws_api_gateway_integration.appointment_customers_delete_integration.id,
      aws_api_gateway_integration.organization_any_integration.id,
      aws_api_gateway_integration.organization_closing_times_integration.id,
      aws_api_gateway_integration.organization_opening_hours_integration.id,
      aws_api_gateway_integration.organization_working_hours_integration.id,
      aws_api_gateway_integration.organization_working_hours_post_integration.id,
      aws_api_gateway_integration.organization_opening_hours_integration_post.id,
      aws_api_gateway_integration.organization_employees_integration.id,
      aws_api_gateway_integration.organization_employees_integration_post.id,
      aws_api_gateway_integration.organizations_get_integration.id,
      aws_api_gateway_integration.organization_get_integration.id,
      aws_api_gateway_integration.organizationappointment_any_integration.id,
      aws_api_gateway_integration.organizationappointment_slots_integration.id,
      aws_api_gateway_integration.organizationappointment_appointments_delete_integration.id,
      aws_api_gateway_integration.payment_any_integration.id,
      aws_api_gateway_integration.payment_stripe_post_integration.id
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id        = aws_api_gateway_deployment.deployment.id
  rest_api_id          = aws_api_gateway_rest_api.api.id
  stage_name           = var.environment
  xray_tracing_enabled = true
}

resource "aws_api_gateway_authorizer" "authorizer" {
  name                             = "authorizer"
  rest_api_id                      = aws_api_gateway_rest_api.api.id
  authorizer_uri                   = module.authorizer-application.invoke_arn
  authorizer_credentials           = aws_iam_role.invocation_role.arn
  # Caching for 5 Minutes
  authorizer_result_ttl_in_seconds = 300
}

resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": "${module.authorizer-application.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda" {
  name = "demo-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
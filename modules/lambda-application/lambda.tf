resource "aws_lambda_function" "lambda" {
  function_name = var.application_name

  s3_bucket = var.s3_bucket_id
  s3_key    = "${var.application_name}.zip"

  runtime = var.runtime
  handler = var.handler

  role = aws_iam_role.lambda_role.arn

  memory_size = 512
  timeout     = 30

  environment {
    variables = var.environment_variables
  }

  tags = {
    ResourceGroup = "apnmt-aws"
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "serverless_lambda_${var.application_name}"

  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.lambda.function_name}"

  retention_in_days = 30

  tags = {
    ResourceGroup = "apnmt-aws"
  }
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
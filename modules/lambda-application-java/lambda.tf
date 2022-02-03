resource "aws_lambda_function" "lambda" {
  function_name = var.application_name

  s3_bucket = var.s3_bucket_id
  s3_key    = "${var.application_name}.jar"

  runtime = "java11"
  handler = var.handler

  role = aws_iam_role.lambda_role.arn

  memory_size = 512
  timeout     = 30

  environment {
    variables = var.environment_variables
  }
}

resource "aws_iam_role" "lambda_role" {
  name = "serverless_lambda"

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
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
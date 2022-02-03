output invoke_arn {
  description = "The Lambda Function invoke arn"
  value       = aws_lambda_function.lambda.invoke_arn
}

output function_name {
  description = "The Lambda Function name"
  value       = aws_lambda_function.lambda.function_name
}
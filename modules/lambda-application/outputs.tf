output arn {
  description = "The Lambda Function arn"
  value       = aws_lambda_function.lambda.arn
}

output invoke_arn {
  description = "The Lambda Function invoke arn"
  value       = aws_lambda_function.lambda.invoke_arn
}

output function_name {
  description = "The Lambda Function name"
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_role_name" {
  description = "The Name of the Lambda IAM Role"
  value       = aws_iam_role.lambda_role.name
}
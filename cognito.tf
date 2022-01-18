resource "aws_cognito_user_pool" "apnmt_user_pool" {
  name = "apnmtUserPool"
}

resource "aws_cognito_user_pool_client" "apnmt_user_pool_client" {
  name                = "apnmtUserPoolClient"
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  user_pool_id = aws_cognito_user_pool.apnmt_user_pool.id
}
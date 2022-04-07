data "aws_cognito_user_pools" "apnmt_user_pool" {
  name = "apnmtUserPool"
}

data "aws_cognito_user_pool_clients" "apnmt_user_pool_client" {
  user_pool_id = data.aws_cognito_user_pools.apnmt_user_pool.ids.0
}
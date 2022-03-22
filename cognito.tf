resource "aws_cognito_user_pool" "apnmt_user_pool" {
  name = "apnmtUserPool"
}

resource "aws_cognito_user_pool_client" "apnmt_user_pool_client" {
  name                = "apnmtUserPoolClient"
  explicit_auth_flows = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH"]

  user_pool_id = aws_cognito_user_pool.apnmt_user_pool.id
}

resource "aws_iam_role" "group_role" {
  name = "user-group-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "us-east-1:12345678-dead-beef-cafe-123456790ab"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_cognito_user_group" "user" {
  name         = "user"
  user_pool_id = aws_cognito_user_pool.apnmt_user_pool.id
  description  = "User Group"
  precedence   = 42
  role_arn     = aws_iam_role.group_role.arn
}

resource "aws_cognito_user_group" "manager" {
  name         = "manager"
  user_pool_id = aws_cognito_user_pool.apnmt_user_pool.id
  description  = "Manager Group"
  precedence   = 42
  role_arn     = aws_iam_role.group_role.arn
}

resource "aws_cognito_user_group" "admin" {
  name         = "admin"
  user_pool_id = aws_cognito_user_pool.apnmt_user_pool.id
  description  = "Admin Group"
  precedence   = 42
  role_arn     = aws_iam_role.group_role.arn
}
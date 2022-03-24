module "authorizer-application" {
  source = "./modules/lambda-application"

  application_name      = "authorizer"
  handler               = "lambda.handler"
  s3_bucket_id          = var.s3_bucket_id
  public_subnets        = module.vpc.public_subnets
  private_subnets       = module.vpc.private_subnets
  vpc_id                = module.vpc.vpc_id
  region                = var.region
  runtime               = "python3.9"
  environment_variables = {
    TABLE_NAME           = aws_dynamodb_table.auth-policy-store.name,
    AWS_LAMBDA_REGION    = var.region,
    COGNITO_USER_POOL_ID = aws_cognito_user_pool.apnmt_user_pool.id
  }
}

resource "aws_dynamodb_table" "auth-policy-store" {
  name           = "auth-policy-store"
  hash_key       = "group"
  read_capacity  = 10
  write_capacity = 10
  attribute {
    name = "group"
    type = "S"
  }
  tags           = {
    environment = var.environment
  }
}

resource "aws_iam_role_policy_attachment" "authorizer_dynamo_db_policy_attach" {
  role       = module.authorizer-application.lambda_role_name
  policy_arn = aws_iam_policy.authorizer_dynamo_db_policy.arn
}

resource "aws_iam_policy" "authorizer_dynamo_db_policy" {
  policy = data.aws_iam_policy_document.authorizer_dynamo_db.json
}

data "aws_iam_policy_document" "authorizer_dynamo_db" {
  statement {
    sid = "ReadTable"

    effect = "Allow"

    actions = [
      "dynamodb:BatchGetItem"
    ]

    resources = [aws_dynamodb_table.auth-policy-store.arn]
  }
}

resource "aws_dynamodb_table_item" "admin" {
  table_name = aws_dynamodb_table.auth-policy-store.name
  hash_key   = aws_dynamodb_table.auth-policy-store.hash_key

  item = <<ITEM
{
 "group": {
  "S": "admin"
 },
 "policy": {
  "M": {
   "Version": {
    "S": "2012-10-17"
   },
   "Statement": {
    "L": [
     {
      "M": {
       "Resource": {
        "L": [
         {
          "S": "arn:aws:execute-api:*:*:*/*/*/*"
         }
        ]
       },
       "Action": {
        "S": "execute-api:Invoke"
       },
       "Effect": {
        "S": "Allow"
       },
       "Sid": {
        "S": "APNMT-API"
       }
      }
     }
    ]
   }
  }
 }
}
ITEM
}

resource "aws_dynamodb_table_item" "manager" {
  table_name = aws_dynamodb_table.auth-policy-store.name
  hash_key   = aws_dynamodb_table.auth-policy-store.hash_key

  item = <<ITEM
{
 "group": {
  "S": "manager"
 },
 "policy": {
  "M": {
   "Version": {
    "S": "2012-10-17"
   },
   "Statement": {
    "L": [
     {
      "M": {
       "Resource": {
        "L": [
         {
          "S": "arn:aws:execute-api:*:*:*/*/ANY/service/appointment/api/services/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/ANY/service/organization/**"
         }
        ]
       },
       "Action": {
        "S": "execute-api:Invoke"
       },
       "Effect": {
        "S": "Allow"
       },
       "Sid": {
        "S": "APNMT-API"
       }
      }
     },
     {
      "M": {
       "Resource": {
        "L": [
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/appointment/api/customers"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/POST/service/payment/api/products/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/PUT/service/payment/api/products/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/POST/service/payment/api/prices/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/PUT/service/payment/api/prices/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/payment/api/customers/**"
         }
        ]
       },
       "Action": {
        "S": "execute-api:Invoke"
       },
       "Effect": {
        "S": "DENY"
       },
       "Sid": {
        "S": "APNMT-API"
       }
      }
     }
    ]
   }
  }
 }
}
ITEM
}

resource "aws_dynamodb_table_item" "user" {
  table_name = aws_dynamodb_table.auth-policy-store.name
  hash_key   = aws_dynamodb_table.auth-policy-store.hash_key

  item = <<ITEM
{
 "group": {
  "S": "user"
 },
 "policy": {
  "M": {
   "Version": {
    "S": "2012-10-17"
   },
   "Statement": {
    "L": [
     {
      "M": {
       "Resource": {
        "L": [
         {
          "S": "arn:aws:execute-api:*:*:*/*/POST/service/appointment/api/appointments"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/PUT/service/appointment/api/appointments/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/DELETE/service/appointment/api/appointments/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/appointment/api/appointments/{id}"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/appointment/api/appointments/organization/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/ANY/service/appointment/api/customers/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/appointment/api/customers/organization/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/appointment/api/services/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/organization/api/opening-hours/organization/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/organization/api/working-hours/organization/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/organization/api/closing-times/organization/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/organizationappointment/api/slots"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/ANY/service/payment/**"
         }
        ]
       },
       "Action": {
        "S": "execute-api:Invoke"
       },
       "Effect": {
        "S": "Allow"
       },
       "Sid": {
        "S": "APNMT-API"
       }
      }
     },
     {
      "M": {
       "Resource": {
        "L": [
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/appointment/api/customers"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/POST/service/payment/api/products/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/PUT/service/payment/api/products/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/POST/service/payment/api/prices/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/PUT/service/payment/api/prices/**"
         },
         {
          "S": "arn:aws:execute-api:*:*:*/*/GET/service/payment/api/customers/**"
         }
        ]
       },
       "Action": {
        "S": "execute-api:Invoke"
       },
       "Effect": {
        "S": "DENY"
       },
       "Sid": {
        "S": "APNMT-API"
       }
      }
     }
    ]
   }
  }
 }
}
ITEM
}
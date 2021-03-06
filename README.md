# Provision an APNMT AWS Cluster

## Create AWS Cluster

```
terraform plan
terraform apply
```

## Create Cognito User

```
aws cognito-idp admin-create-user \
--user-pool-id ${userPoolId} \
--username ${username} \
--message-action SUPPRESS
```

Confirm User Password:

```
aws cognito-idp admin-set-user-password \
--user-pool-id ${userPoolId} \
--username "${username}" \
--password "${password}" \
--permanent
```

## Login with User

```
curl --location --request POST 'https://cognito-idp.eu-central-1.amazonaws.com' --header 'X-Amz-Target: AWSCognitoIdentityProviderService.InitiateAuth' --header 'Content-Type: application/x-amz-json-1.1' --data-raw '{
"AuthParameters" : {
"USERNAME" : "${username}",
"PASSWORD" : "${password}"
},
"AuthFlow" : "USER_PASSWORD_AUTH",
"ClientId" : "${clientId}"
}'
```

Use IdToken to authenticate to Cognito

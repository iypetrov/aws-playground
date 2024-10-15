resource "aws_cognito_user_pool" "gopizza_user_pool" {
  name                     = "gopizza-user-pool"
  auto_verified_attributes = ["email"]
  username_attributes      = ["email"]
  schema {
    name                     = "Email"
    attribute_data_type      = "String"
    mutable                  = true
    developer_only_attribute = false
  }
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }
  tags = {
    "Application" = var.app
    "Owner"       = var.owner
    "Environment" = var.env
    "CreatedAt"   = timestamp()
  }
}

resource "aws_cognito_user_pool_client" "gopizza_user_pool_client" {
  name                          = "gopizza-user-pool-client"
  user_pool_id                  = aws_cognito_user_pool.gopizza_user_pool.id
  supported_identity_providers  = ["COGNITO"]
  explicit_auth_flows           = ["ALLOW_USER_SRP_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
  generate_secret               = false
  prevent_user_existence_errors = "LEGACY"
  id_token_validity             = 1
  access_token_validity         = 1
  refresh_token_validity        = 30
  token_validity_units {
    id_token      = "hours"
    access_token  = "hours"
    refresh_token = "days"
  }
}

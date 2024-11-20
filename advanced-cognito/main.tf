resource "aws_cognito_user_pool" "userpool" {
  name                     = "userpool"
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
}

resource "aws_cognito_user_pool_client" "userpool_client" {
  name                          = "userpool-client"
  user_pool_id                  = aws_cognito_user_pool.userpool.id
  supported_identity_providers  = ["COGNITO", "Google", "Facebook"]
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

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.userpool.id
  provider_name = "Google" 
  provider_type = "Google"

  provider_details = {
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
    authorize_scopes = "email profile openid"
  }
}

resource "aws_cognito_identity_provider" "facebook" {
  user_pool_id  = aws_cognito_user_pool.userpool.id
  provider_name = "Facebook" 
  provider_type = "Facebook"

  provider_details = {
    client_id        = var.facebook_client_id
    client_secret    = var.facebook_client_secret
    authorize_scopes = "email public_profile"
  }
}

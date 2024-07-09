locals {
  user_info = jsondecode(file("${path.module}/users.json"))
}

resource "random_string" "random" {
  length  = 16
  special = false
  upper   = false
  lower   = true
  numeric = true
}

resource "aws_cognito_user_pool" "store_pool" {
  name = "store-users"
  username_configuration {
    case_sensitive = true
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "preferred_username"
    required                 = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "given_name"
    required                 = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "family_name"
    required                 = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "address"
    required                 = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "phone"
    required                 = false
    string_attribute_constraints {
      min_length = 8
      max_length = 20
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "email"
    required                 = false
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 7
  }
}

# resource "aws_dynamodb_table" "store-users" {
#     name           = "store-users"
#     billing_mode   = "PAY_PER_REQUEST"
#     hash_key       = "username"
#     stream_enabled = true
#     stream_view_type = "NEW_AND_OLD_IMAGES"

#     attribute {
#         name = "username"
#         type = "S"
#     }
# }

# resource "aws_dynamodb_table_item" "users" {
#     for_each = { for user in local.user_info.users : user.username => user }
#     table_name = aws_dynamodb_table.store-users.name
#     hash_key = aws_dynamodb_table.store-users.hash_key
#     item = <<EOF
# {
#     "username": {"S": "${each.key}"},
#     "first": {"S": "${each.value.first}"},
#     "last": {"S": "${each.value.last}"},
#     "street": {"S": "${each.value.street}"},
#     "city": {"S": "${each.value.city}"},
#     "state": {"S": "${each.value.state}"},
#     "country": {"S": "${each.value.country}"},
#     "phone": {"S": "${each.value.phone}"},
#     "password": {"S": "${each.value.password}"}
# }
# EOF
# }

resource "aws_cognito_user" "user" {
  for_each       = { for user in local.user_info.users : user.username => user }
  username       = each.value.username
  password       = each.value.password
  user_pool_id   = aws_cognito_user_pool.store_pool.id
  message_action = "SUPPRESS"

  attributes = {
    given_name     = each.value.first
    family_name    = each.value.last
    address        = format("%s, %s, %s, %s", each.value.street, each.value.city, each.value.state, each.value.country)
    email          = each.value.email
    phone          = each.value.phone
    email_verified = true
  }
}

resource "aws_cognito_user_pool_client" "store_upc" {
  name                                 = "client"
  user_pool_id                         = aws_cognito_user_pool.store_pool.id
  callback_urls                        = ["https://example.com"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code", "implicit"]
  allowed_oauth_scopes                 = ["email", "openid"]
  supported_identity_providers         = ["COGNITO"]
}

resource "aws_cognito_user_pool_domain" "main_domain" {
  domain       = random_string.random.result
  user_pool_id = aws_cognito_user_pool.store_pool.id
}

resource "aws_cognito_user_pool_ui_customization" "login_ui_customization" {
  client_id = aws_cognito_user_pool_client.store_upc.id
  css        = ".label-customizable {font-weight: 400;}"
  image_file = filebase64("${path.module}/webcode/store/static/waynestock-logo.png")
  user_pool_id = aws_cognito_user_pool_domain.main_domain.user_pool_id
}

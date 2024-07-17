locals {
  user_info = jsondecode(file("${path.module}/users.json"))
  seats = jsondecode(file("${path.module}/seats.json"))
  content_types = {
    css  = "text/css"
    html = "text/html"
    js   = "application/javascript"
    json = "application/json"
    txt  = "text/plain"
  }
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

resource "aws_dynamodb_table" "store_seats" {
    name           = "seats"
    billing_mode   = "PAY_PER_REQUEST"
    hash_key       = "section"
    range_key      = "seat_id"
    stream_enabled = true
    stream_view_type = "NEW_AND_OLD_IMAGES"

    attribute {
        name = "seat_id"
        type = "S"
    }
    attribute {
        name = "section"
        type = "N"
    }
}

resource "aws_dynamodb_table_item" "seats" {
    for_each = { for seat in local.seats.seatingChart : seat.seat_id => seat }
    table_name = aws_dynamodb_table.store_seats.name
    hash_key = aws_dynamodb_table.store_seats.hash_key
    range_key = aws_dynamodb_table.store_seats.range_key
    item = <<EOF
{
    "section": {"N": "${each.value.section}"},
    "row": {"N": "${each.value.row}"},
    "seat": {"N": "${each.value.seat}"},
    "seat_id": {"S": "${each.value.seat_id}"},
    "available": {"BOOL": ${each.value.available}}
}
EOF
}

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
  name         = "client"
  user_pool_id = aws_cognito_user_pool.store_pool.id
  callback_urls = [
    "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
  ]
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
  client_id    = aws_cognito_user_pool_client.store_upc.id
  css          = ".label-customizable {font-weight: 400;}"
  image_file   = filebase64("${path.module}/webcode/store/client/src/images/waynestock-logo.png")
  user_pool_id = aws_cognito_user_pool_domain.main_domain.user_pool_id
}

resource "aws_s3_bucket" "store_static" {
  bucket = "storestatic${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_object" "store_static_files" {
  for_each         = fileset("${path.module}/webcode/store/client/build", "**/*")
  bucket           = aws_s3_bucket.store_static.bucket
  key              = each.value
  source           = "${path.module}/webcode/store/client/build/${each.value}"
  content_type     = lookup(local.content_types, element(split(".", each.value), length(split(".", each.value)) - 1), "text/plain")
  content_encoding = "utf-8"
  source_hash = filemd5("${path.module}/webcode/store/client/build/${each.value}")
}

resource "aws_s3_bucket" "store_transactions" {
  bucket = "storetransactions${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket" "volunteers" {
  bucket = "volunteers${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_bucket" "volunteers_webcode" {
  bucket = "volunteerswebcode${random_string.random.result}"
  force_destroy = true
}

resource "aws_s3_object" "volunteers_static_files" {
  for_each         = fileset("${path.module}/webcode/volunteer/server", "**/*")
  bucket           = aws_s3_bucket.store_static.bucket
  key              = each.value
  source           = "${path.module}/webcode/volunteer/server/${each.value}"
  content_type     = lookup(local.content_types, element(split(".", each.value), length(split(".", each.value)) - 1), "text/plain")
  content_encoding = "utf-8"
  source_hash = filemd5("${path.module}/webcode/volunteer/server/${each.value}")
}

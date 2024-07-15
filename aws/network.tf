locals {
  s3_origin_id    = "S3Origin"
  apigw_origin_id = "APIGatewayOrigin"
}

resource "aws_apigatewayv2_api" "store_api" {
  name          = "store_api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_authorizer" "store_auth" {
  api_id           = aws_apigatewayv2_api.store_api.id
  authorizer_type  = "JWT"
  identity_sources = ["$request.header.Authorization"]
  name             = "cognito-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.store_upc.id]
    issuer   = "https://${aws_cognito_user_pool.store_pool.endpoint}"
  }
}

resource "aws_apigatewayv2_integration" "login_int" {
  api_id                 = aws_apigatewayv2_api.store_api.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.redirect_login.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "seats_int" {
  api_id                 = aws_apigatewayv2_api.store_api.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.get_seats.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_integration" "purchase_int" {
  api_id                 = aws_apigatewayv2_api.store_api.id
  integration_type       = "AWS_PROXY"
  connection_type        = "INTERNET"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.purchase_seats.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "login" {
  api_id             = aws_apigatewayv2_api.store_api.id
  route_key          = "GET /login"
  target             = "integrations/${aws_apigatewayv2_integration.login_int.id}"
  authorization_type = "NONE"
}

resource "aws_apigatewayv2_route" "get_seats" {
  api_id             = aws_apigatewayv2_api.store_api.id
  route_key          = "GET /seats"
  target             = "integrations/${aws_apigatewayv2_integration.seats_int.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.store_auth.id
}

resource "aws_apigatewayv2_route" "purchase_seats" {
  api_id             = aws_apigatewayv2_api.store_api.id
  route_key          = "POST /purchase"
  target             = "integrations/${aws_apigatewayv2_integration.purchase_int.id}"
  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.store_auth.id
}

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id        = aws_apigatewayv2_api.store_api.id
  name          = var.stage
  deployment_id = aws_apigatewayv2_deployment.dev_deploy.id
}

resource "aws_apigatewayv2_deployment" "dev_deploy" {
  api_id      = aws_apigatewayv2_api.store_api.id
  description = "Store deployment"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_apigatewayv2_integration.purchase_int,
    aws_apigatewayv2_integration.login_int,
    aws_apigatewayv2_integration.seats_int,
    aws_apigatewayv2_route.purchase_seats,
    aws_apigatewayv2_route.login,
    aws_apigatewayv2_route.get_seats
  ]
}

resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "s3-origin-access-control"
  description                       = "S3 Origin Access Control"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name              = aws_s3_bucket.store_static.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.s3_oac.id
    origin_id                = local.s3_origin_id
  }

  origin {
    domain_name = replace(aws_apigatewayv2_api.store_api.api_endpoint, "/^https?://([^/]*).*/", "$1")
    origin_id   = local.apigw_origin_id

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  ordered_cache_behavior {
    path_pattern     = "/api/*"
    allowed_methods  = ["HEAD", "DELETE", "POST", "GET", "OPTIONS", "PUT", "PATCH"]
    cached_methods   = ["GET", "OPTIONS", "HEAD"]
    compress         = false
    target_origin_id = local.apigw_origin_id
    forwarded_values {
      query_string = true
      headers = [
        "Authorization"
      ]
      cookies {
        forward = "all"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id
    compress         = false

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.root_object.arn
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 0
  }

  price_class = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

resource "aws_cloudfront_function" "root_object" {
  name    = "root_object"
  runtime = "cloudfront-js-2.0"
  comment = "my function"
  publish = true
  code    = <<EOF
function handler(event) {
    var request = event.request;
    var uri = request.uri;
    if (uri == '/') {
        request.uri += 'index.html';
    } 
    // Check whether the URI is missing a file extension.
    else if (!uri.includes('.')) {
        request.uri += '/index.html';
    }

    return request;
}
EOF
}

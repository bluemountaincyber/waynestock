resource "aws_apigatewayv2_api" "store_api" {
  name = "store_api"
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

resource "aws_apigatewayv2_integration" "store_int" {
  api_id           = aws_apigatewayv2_api.store_api.id
  integration_type = "HTTP_PROXY"
  connection_type = "INTERNET"
  integration_method = "GET"
  integration_uri = "https://example.com"
}

resource "aws_apigatewayv2_route" "route" {
  api_id    = aws_apigatewayv2_api.store_api.id
  route_key = "GET /buy"
  target = "integrations/${aws_apigatewayv2_integration.store_int.id}"
  authorization_type = "JWT"
  authorizer_id = aws_apigatewayv2_authorizer.store_auth.id
}

resource "aws_apigatewayv2_stage" "dev_stage" {
  api_id = aws_apigatewayv2_api.store_api.id
  name   = "dev"
  deployment_id = aws_apigatewayv2_deployment.dev_deploy.id
}

resource "aws_apigatewayv2_deployment" "dev_deploy" {
  api_id      = aws_apigatewayv2_api.store_api.id
  description = "Store deployment"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ 
    aws_apigatewayv2_integration.store_int,
    aws_apigatewayv2_route.route
  ]
}

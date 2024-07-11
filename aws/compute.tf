data "archive_file" "redirect_login" {
    type        = "zip"
    output_path = "${path.module}/webcode/store/redirect_login.zip"
    source {
        content = templatefile("${path.module}/webcode/store/redirect-login/lambda_function.py.tftpl", {
            LOGIN_URL = "https://${aws_cognito_user_pool.store_pool.domain}.auth.${var.region}.amazoncognito.com/oauth2/authorize?client_id=${aws_cognito_user_pool_client.store_upc.id}&response_type=token&scope=email+openid&redirect_uri=${urlencode("${aws_apigatewayv2_api.store_api.api_endpoint}/dev/buy")}"
        })
        filename = "lambda_function.py"
    }
}

resource "aws_lambda_function" "redirect_login" {
    filename         = data.archive_file.redirect_login.output_path
    function_name    = "redirect_login"
    role             = aws_iam_role.redirect_lambda.arn
    handler          = "lambda_function.lambda_handler"
    source_code_hash = data.archive_file.redirect_login.output_base64sha256
    runtime          = "python3.12"
    timeout          = 3
    memory_size      = 128
}

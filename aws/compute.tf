data "archive_file" "redirect_login" {
  type        = "zip"
  output_path = "${path.module}/webcode/store/redirect_login.zip"
  source {
    content = templatefile("${path.module}/webcode/store/redirect-login/lambda_function.py.tftpl", {
      LOGIN_URL = "https://${aws_cognito_user_pool.store_pool.domain}.auth.${var.region}.amazoncognito.com/oauth2/authorize?client_id=${aws_cognito_user_pool_client.store_upc.id}&response_type=token&scope=email+openid&redirect_uri=${urlencode("https://${aws_cloudfront_distribution.s3_distribution.domain_name}")}"
    })
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "redirect_login" {
  filename         = data.archive_file.redirect_login.output_path
  function_name    = "store_redirect_login"
  role             = aws_iam_role.redirect_lambda.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.redirect_login.output_base64sha256
  runtime          = "python3.12"
  timeout          = 3
  memory_size      = 128
}

data "archive_file" "get_seats" {
  type        = "zip"
  output_path = "${path.module}/webcode/store/get_seats.zip"
  source {
    content = file("${path.module}/webcode/store/get-seats/lambda_function.py")
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "get_seats" {
  filename         = data.archive_file.get_seats.output_path
  function_name    = "store_get_seats"
  role             = aws_iam_role.get_seats.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.get_seats.output_base64sha256
  runtime          = "python3.12"
  timeout          = 10
  memory_size      = 128
}

data "archive_file" "purchase_seats" {
  type        = "zip"
  output_path = "${path.module}/webcode/store/purchase_seats.zip"
  source {
    content = templatefile("${path.module}/webcode/store/purchase-seats/lambda_function.py.tftpl", {
      S3_BUCKET = aws_s3_bucket.store_transactions.bucket
    })
    filename = "lambda_function.py"
  }
}

resource "aws_lambda_function" "purchase_seats" {
  filename         = data.archive_file.purchase_seats.output_path
  function_name    = "store_purchase_seats"
  role             = aws_iam_role.purchase_seats.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.purchase_seats.output_base64sha256
  runtime          = "python3.12"
  timeout          = 30
  memory_size      = 128
}

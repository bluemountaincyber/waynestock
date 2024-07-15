resource "aws_cloudwatch_log_group" "redirect_login" {
  name              = "/aws/lambda/store_redirect_login"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "get_seats" {
  name              = "/aws/lambda/store_get_seats"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "purchase_seats" {
  name              = "/aws/lambda/store_purchase_seats"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "redirect_login" {
  name              = "/aws/lambda/store_redirect_login"
  retention_in_days = 7
}

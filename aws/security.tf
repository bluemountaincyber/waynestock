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

resource "aws_cloudwatch_log_group" "waynestock-apigw" {
  name              = "waynestock-apigw"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "volunteers-syslog" {
  name              = "/volunteers/audit"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_group" "volunteers-httpd" {
  name              = "/volunteers/httpd-access"
  retention_in_days = 7
}

resource "aws_securityhub_account" "security_hub" {
  enable_default_standards = false
  depends_on = [ aws_config_configuration_recorder_status.crs ]
}

resource "aws_securityhub_standards_subscription" "aws_best_practices" {
  depends_on = [ aws_securityhub_account.security_hub ]
  standards_arn = "arn:aws:securityhub:${var.region}::standards/aws-foundational-security-best-practices/v/1.0.0"
}

resource "aws_config_configuration_recorder" "cr" {
  name     = "waynestockcr"
  role_arn = aws_iam_role.config_role.arn
}

resource "aws_config_delivery_channel" "dc" {
  name           = "waynestockdc"
  s3_bucket_name = aws_s3_bucket.config.bucket
  depends_on     = [aws_config_configuration_recorder.cr]
}

resource "aws_config_configuration_recorder_status" "crs" {
  name = aws_config_configuration_recorder.cr.name
  is_enabled = true
  depends_on = [ aws_config_delivery_channel.dc ]
}

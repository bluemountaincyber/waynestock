output "store_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "volunteers_url" {
  value = "http://${aws_instance.volunteers.public_ip}"
}

output "user_pool_domain" {
  value = aws_cognito_user_pool_domain.main_domain.domain
}

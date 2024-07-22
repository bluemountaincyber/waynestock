output "store_url" {
  value = "https://${aws_cloudfront_distribution.s3_distribution.domain_name}"
}

output "volunteers_url" {
  value = "http://${aws_instance.volunteers.public_ip}"
}
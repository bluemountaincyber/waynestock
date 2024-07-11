data "aws_iam_policy_document" "redirect_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "redirect_lambda" {
  name        = "RedirectLambdaPolicy"
  description = "Policy for redirect lambda"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "redirect_lambda" {
  name               = "RedirectLambda"
  assume_role_policy = data.aws_iam_policy_document.redirect_assume_role.json
}

resource "aws_iam_role_policy_attachment" "redirect_lambda" {
  role       = aws_iam_role.redirect_lambda.name
  policy_arn = aws_iam_policy.redirect_lambda.arn
}

resource "aws_lambda_permission" "apigw_login" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect_login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.store_api.execution_arn}/*/*/*"
}

resource "aws_s3_bucket_policy" "store_static" {
  bucket = aws_s3_bucket.store_static.bucket
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow",
        Principal = {
          Service = "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.store_static.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.s3_distribution.arn
          }
        }
      }
    ]
  })
}

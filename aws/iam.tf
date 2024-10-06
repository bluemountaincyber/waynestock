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

resource "aws_iam_policy" "get_seats" {
  name        = "GetSeatsLambdaPolicy"
  description = "Policy for get-seats"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.store_seats.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "get_seats" {
  name               = "GetSeatsLambda"
  assume_role_policy = data.aws_iam_policy_document.redirect_assume_role.json
}

resource "aws_iam_role_policy_attachment" "get_seats" {
  role       = aws_iam_role.get_seats.name
  policy_arn = aws_iam_policy.get_seats.arn
}

resource "aws_iam_policy" "purchase_seats" {
  name        = "PurchaseSeatsLambdaPolicy"
  description = "Policy for purchase-seats"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:*"
        ]
        Resource = aws_dynamodb_table.store_seats.arn
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.store_transactions.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role" "purchase_seats" {
  name               = "PurchaseSeatsLambda"
  assume_role_policy = data.aws_iam_policy_document.redirect_assume_role.json
}

resource "aws_iam_role_policy_attachment" "purchase_seats" {
  role       = aws_iam_role.purchase_seats.name
  policy_arn = aws_iam_policy.purchase_seats.arn
}

resource "aws_lambda_permission" "apigw_login" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.redirect_login.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.store_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "apigw_seats" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.get_seats.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.store_api.execution_arn}/*/*/*"
}

resource "aws_lambda_permission" "apigw_purchase" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.purchase_seats.function_name
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

data "aws_iam_policy_document" "volunteer_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_policy" "volunteer" {
  name        = "VolunteerPolicy"
  description = "Policy for volunteer"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:List*"
        ]
        Resource = "*"

      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "${aws_s3_bucket.volunteers_webcode.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject"
        ]
        Resource = "${aws_s3_bucket.volunteers.arn}/*"
      }
    ]
  })
}

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "cloudwatch" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role" "volunteer" {
  name               = "VolunteerRole"
  assume_role_policy = data.aws_iam_policy_document.volunteer_assume_role.json
}

resource "aws_iam_role_policy_attachment" "volunteer" {
  role       = aws_iam_role.volunteer.name
  policy_arn = aws_iam_policy.volunteer.arn
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.volunteer.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.volunteer.name
  policy_arn = data.aws_iam_policy.cloudwatch.arn
}

resource "aws_iam_instance_profile" "volunteer" {
  name = "VolunteerInstanceProfile"
  role = aws_iam_role.volunteer.name
}

resource "aws_iam_role" "ssm_role" {
  name = "AutomateSSMRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ssm.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

data "aws_iam_policy" "ssm_automation" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_iam_policy" "update_metadata_options" {
  name = "UpdateMetadataOptions"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:ModifyInstanceMetadataOptions"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ssm_ec2" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = data.aws_iam_policy.ssm_automation.arn
}

resource "aws_iam_role_policy_attachment" "ssm_metadata" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = aws_iam_policy.update_metadata_options.arn
}

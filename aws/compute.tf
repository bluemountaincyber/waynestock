data "archive_file" "redirect_login" {
  type        = "zip"
  output_path = "${path.module}/webcode/store/redirect_login.zip"
  source {
    content = templatefile("${path.module}/webcode/store/redirect-login/lambda_function.py.tftpl", {
      LOGIN_URL = "https://${aws_cognito_user_pool_domain.main_domain.domain}.auth.${var.region}.amazoncognito.com/oauth2/authorize?client_id=${aws_cognito_user_pool_client.store_upc.id}&response_type=token&scope=email+openid&redirect_uri=${urlencode("https://${aws_cloudfront_distribution.s3_distribution.domain_name}")}"
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
    content  = file("${path.module}/webcode/store/get-seats/lambda_function.py")
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

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}
resource "aws_instance" "volunteers" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.volunteer_sg.id]
  subnet_id              = aws_subnet.volunteer_subnet.id
  user_data = templatefile("${path.module}/userdata/volunteer.sh.tftpl", {
    S3_BUCKET = aws_s3_bucket.volunteers_webcode.bucket,
    REGION    = var.region
  })
  iam_instance_profile        = aws_iam_instance_profile.volunteer.name
  associate_public_ip_address = true
  metadata_options {
    http_tokens                 = "optional"
    http_put_response_hop_limit = 1
  }
  tags = {
    Name = "volunteers"
  }
}

resource "aws_ssm_document" "session_manager_prefs" {
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<DOC
{
  "schemaVersion": "1.0",
  "description": "Document to hold regional settings for Session Manager",
  "sessionType": "Standard_Stream",
  "inputs": {
    "s3BucketName": "",
    "s3KeyPrefix": "",
    "s3EncryptionEnabled": true,
    "cloudWatchLogGroupName": "",
    "cloudWatchEncryptionEnabled": "false",
    "cloudWatchStreamingEnabled": false,
    "idleSessionTimeout": "60",
    "maxSessionDuration": "120",
    "kmsKeyId": "",
    "runAsEnabled": false,
    "runAsDefaultUser": "",
    "shellProfile": {
      "windows": "",
      "linux": "sudo su - student\ncd /home/student\nclear"
    }
  }
}
DOC
}

resource "aws_lambda_function" "this" {
  function_name    = var.name
  description      = "Created by Terraform"
  role             = aws_iam_role.lambda_exec.arn
  runtime          = "nodejs18.x"
  handler          = "lambda-function.handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

data "archive_file" "lambda_zip" {
  output_path = "lambda-function.zip"
  type        = "zip"
  source {
    content  = ""
    filename = file("${path.module}/lambda-function.js")
  }
}

resource "aws_iam_role" "lambda_exec" {
  name = "${var.name}-iam-role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:CreateRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "lambda_policy" {
  name   = "${var.name}-iam-rolee-policy"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:*"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:logs:*:*:*"
    },
    {
      "Action": [
        "lambda:InvokeFunction"
      ],
      "Effect": "Allow",
      "Resource": "${aws_lambda_function.this.arn}"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "lambda" {
  name       = "${var.name}-iam-policy-attachment"
  roles      = [aws_iam_role.lambda_exec.name]
  policy_arn = aws_iam_policy.lambda_policy.arn
}
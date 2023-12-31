data "aws_region" "current" {}
data "aws_caller_identity" "current" {}


# Lambda IAM role creation
resource "aws_iam_role" "workshop-lambda_role" {
  name = "workshop-lambda-${var.layer}-role"
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Action" : "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "LambdaPolicy" {
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action": [
          "logs:*"
        ],
        "Resource": "arn:aws:logs:*:*:*",
        "Effect": "Allow"
      },
      {
        "Effect": "Allow",
        "Action": [
            "states:StartExecution"
        ],
        "Resource" : var.state_machine_arn
      },
      {
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "s3:PutObject",
            "s3:ListBucket"
        ],
        "Resource" : [
          var.s3_bucket_arn,
          "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}


# Attach the IAM policies to the equivalent rule
resource "aws_iam_role_policy_attachment" "LambdaPolicyAttachment" {
  role       = aws_iam_role.workshop-lambda_role.name
  policy_arn = aws_iam_policy.LambdaPolicy.arn
}

# Lambda creation
resource "aws_lambda_function" "workshop-lambda" {
  function_name    = "workshop-lambda-${var.layer}"
  handler          = var.handler
  runtime          = var.runtime
  role             = aws_iam_role.workshop-lambda_role.arn
  /*
  NOTE: ${path.module} is a special Terraform interpolation function that returns the filesystem path of the directory
        where the currently executing Terraform configuration files are located. It's a convenient way to reference files
        or directories relative to your Terraform configuration, regardless of where your Terraform code is located.
  */
  source_code_hash = filebase64sha256(var.zip_location)
  filename         = var.zip_location
  timeout          = var.timeout
  layers           = ["arn:aws:lambda:us-east-1:336392948345:layer:AWSSDKPandas-Python39:11"]


  environment {
    variables = {
      AUTH_TOKEN = "1q2w3e4r5t",  # A good practice is to use AWS Secrets Manager to store secrets and sensitive info but for this workshop we will use a simple variable
      S3_BUCKET_NAME = var.s3_bucket_name,
    }
  }
}

output "lambda_arn" {
  value = aws_lambda_function.workshop-lambda.arn
}

output "lambda_name" {
  value = aws_lambda_function.workshop-lambda.function_name
}

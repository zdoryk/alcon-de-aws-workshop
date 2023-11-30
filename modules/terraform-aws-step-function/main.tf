# AWS Step Functions IAM roles and Policies
resource "aws_iam_role" "sfn_role" {
  name = "workshop-sfn-role"
  assume_role_policy = <<EOF
{
   "Version": "2012-10-17",
   "Statement": [
      {
         "Action": "sts:AssumeRole",
         "Principal": {
            "Service": [
                "states.amazonaws.com"
            ]
         },
         "Effect": "Allow",
         "Sid": "StepFunctionAssumeRole"
      }
   ]
}
EOF
}

resource "aws_iam_role_policy" "sfn_policy" {
  name    = "workshop-sfn-policy"
  role    = aws_iam_role.sfn_role.id

  policy  = <<EOF
{
   "Version":"2012-10-17",
   "Statement":[
      {
         "Action": [
                "glue:StartJobRun",
                "glue:GetJobRun",
                "glue:GetJobRuns",
                "glue:BatchStopJobRun"
         ],
         "Effect": "Allow",
         "Resource": "${var.glue_job_arn}"
      },
      {
        "Action": [
          "lambda:InvokeFunction",
          "lambda:GetFunction",
          "lambda:ListFunctions"
        ],
        "Effect": "Allow",
        "Resource": [
          "${var.lambda_raw_arn}",
          "${var.lambda_trusted_arn}"
        ]
      }
  ]
}

EOF
}

# AWS Step function definition
resource "aws_sfn_state_machine" "sfn_workflow" {
  name = "workshop-sfn-workflow"
  role_arn   = aws_iam_role.sfn_role.arn
  definition = jsonencode({
    "Comment":"A description of the simple state machine using Terraform",
    "StartAt":"Lambda Raw",
    "States":{
      "Lambda Raw":{
        Type     = "Task",
        Resource = var.lambda_raw_arn,
        Next     = "Lambda Trusted"  # Name of the next state, not the resource name
      },
      "Lambda Trusted":{
        Type     = "Task",
        Resource = var.lambda_trusted_arn,
        Next     = "Glue Enriched"  # Name of the next state, not the resource name
      },
      "Glue Enriched":{
        "Type": "Task",
        "Resource": "arn:aws:states:::glue:startJobRun.sync",
        "Parameters": {
          "JobName": var.glue_job_name,
          "Arguments": {
            "--S3_BUCKET_NAME": var.s3_data_bucket_name
          }
        },
        "End": true
      }
    }
  })
}


# outputs
output "sfn_role_arn" {
  value = aws_iam_role.sfn_role.arn
}
output "sfn_name" {
  value = aws_sfn_state_machine.sfn_workflow
}
output "sfn_arn" {
  value = aws_sfn_state_machine.sfn_workflow.arn
}

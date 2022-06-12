# Daily-running lambda function that syncs API data with S3 bucket data
module "daily_lambda" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "daily_lambda"
  description   = "Runs daily to sync API data with S3 bucket"
  handler       = "daily_lambda.get_data"
  runtime       = "python3.9"
  publish       = true
  timeout       = 60

  create_package         = false
  local_existing_package = "./scripts/daily_lambda.zip"

  attach_policy_statements = true
  policy_statements = {
    s3_bucket_access = {
      effect    = "Allow",
      actions   = ["s3:ListBucket", "s3:PutObject", "s3:GetObject", "s3:DeleteObject"],
      resources = ["${module.s3_bucket.s3_bucket_arn}", "${module.s3_bucket.s3_bucket_arn}/*"]
    }
  }
  environment_variables = {
    S3_BUCKET_NAME = "${module.s3_bucket.s3_bucket_id}"
  }

  tags = {
    Name = "Daily API Sync Lambda Function"
  }
}

# Analysis lambda function that reports analysis data to Cloudwatch Logs
module "analysis_lambda" {
  source        = "terraform-aws-modules/lambda/aws"
  function_name = "analysis_lambda"
  description   = "Runs analysis on stored API data from S3 bucket"
  handler       = "analysis_lambda.report_data"
  runtime       = "python3.9"
  publish       = true

  attach_policy_statements = true
  policy_statements = {
    sqs = {
      effect    = "Allow",
      actions   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
      resources = ["${aws_sqs_queue.queue.arn}"]
    }
  }

  create_package         = false
  local_existing_package = "./scripts/analysis_lambda.zip"
  environment_variables = {
    S3_BUCKET_NAME = "${module.s3_bucket.s3_bucket_id}"
  }

  tags = {
    Name = "Data Analysis Lambda Function"
  }
}

# S3 bucket for storing API data
module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  acl    = "private"
  versioning = {
    enabled = false
  }
}

# Bucket policy allowing public read access
resource "aws_s3_bucket_policy" "s3_public_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "${module.s3_bucket.s3_bucket_arn}/*"
        }
    ]
  }
  EOF
}

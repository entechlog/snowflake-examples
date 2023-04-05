# Create S3 bucket
resource "aws_s3_bucket" "cloudwatch_logs" {

  bucket        = "${local.resource_name_prefix}-cloudwatch-logs"
  force_destroy = true

}

# Enable versioning in s3
resource "aws_s3_bucket_versioning" "cloudwatch_logs" {

  bucket = aws_s3_bucket.cloudwatch_logs.id
  versioning_configuration {
    status = "Enabled"
  }

}

# Enable encryption in s3
resource "aws_s3_bucket_server_side_encryption_configuration" "cloudwatch_logs" {

  bucket = aws_s3_bucket.cloudwatch_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

}

# Create S3 bucket policy to block public access
resource "aws_s3_bucket_public_access_block" "cloudwatch_logs" {

  bucket                  = aws_s3_bucket.cloudwatch_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}

# Create S3 bucket acl
# resource "aws_s3_bucket_acl" "cloudwatch_logs" {
#   bucket = aws_s3_bucket.cloudwatch_logs.id
#   acl    = "private"
# }


# Resource to add bucket policy to a bucket 
resource "aws_s3_bucket_policy" "cloudwatch_logs" {

  bucket = aws_s3_bucket.cloudwatch_logs.id
  policy = data.aws_iam_policy_document.s3_read_only_policy_document.json

}
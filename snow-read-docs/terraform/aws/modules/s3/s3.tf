# Create S3 bucket
resource "aws_s3_bucket" "this" {

  for_each = toset(var.s3_bucket_name)

  bucket        = replace("${local.resource_name_prefix}-${lower(each.key)}", "_", "-")
  force_destroy = true

  tags = merge(local.tags, {
    Name        = replace("${local.resource_name_prefix}-${lower(each.key)}", "_", "-")
    Environment = "${upper(var.env_code)}"
  })

}

# Enable versioning in s3
resource "aws_s3_bucket_versioning" "this" {

  for_each = toset(var.s3_bucket_name)

  bucket = aws_s3_bucket.this[each.key].id
  versioning_configuration {
    status = "Enabled"
  }

}

# Enable encryption in s3
resource "aws_s3_bucket_server_side_encryption_configuration" "this" {

  for_each = toset(var.s3_bucket_name)

  bucket = aws_s3_bucket.this[each.key].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

}

# Create S3 bucket policy to block public access
resource "aws_s3_bucket_public_access_block" "this" {

  for_each = toset(var.s3_bucket_name)

  bucket                  = aws_s3_bucket.this[each.key].id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


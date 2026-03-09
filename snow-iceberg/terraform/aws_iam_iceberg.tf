# IAM policy for PyIceberg data generator
# Allows writing Iceberg tables to S3 and registering them in Glue Catalog
resource "aws_iam_policy" "iceberg_generator_policy" {
  name        = "${local.aws_resource_prefix}-iceberg-generator-policy"
  description = "Policy for PyIceberg data generator to write Iceberg tables"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3WarehouseAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:ListMultipartUploadParts",
          "s3:AbortMultipartUpload"
        ]
        Resource = [
          "${module.external_volume_bucket.aws_s3_bucket__arn[0]}/*"
        ]
      },
      {
        Sid    = "S3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = module.external_volume_bucket.aws_s3_bucket__arn[0]
      },
      {
        Sid    = "GlueReadAccess"
        Effect = "Allow"
        Action = [
          "glue:GetCatalog",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartition",
          "glue:GetPartitions"
        ]
        Resource = [
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:database/*",
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/*/*"
        ]
      },
      {
        Sid    = "GlueWriteAccess"
        Effect = "Allow"
        Action = [
          "glue:CreateDatabase",
          "glue:UpdateDatabase",
          "glue:CreateTable",
          "glue:UpdateTable",
          "glue:DeleteTable",
          "glue:BatchCreatePartition",
          "glue:BatchDeletePartition",
          "glue:BatchUpdatePartition",
          "glue:CreatePartition",
          "glue:UpdatePartition",
          "glue:DeletePartition"
        ]
        Resource = [
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:catalog",
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:database/*",
          "arn:aws:glue:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/*/*"
        ]
      }
    ]
  })

  tags = local.common_tags
}

# IAM user for data generator
# This user will be used by the PyIceberg generator to write data
resource "aws_iam_user" "iceberg_generator_user" {
  name = "${local.aws_resource_prefix}-iceberg-generator"
  path = "/generators/"

  tags = local.common_tags
}

resource "aws_iam_user_policy_attachment" "iceberg_generator_attachment" {
  user       = aws_iam_user.iceberg_generator_user.name
  policy_arn = aws_iam_policy.iceberg_generator_policy.arn
}

# Access key for the generator user
# Note: In production, use AWS Secrets Manager or similar
resource "aws_iam_access_key" "iceberg_generator_key" {
  user = aws_iam_user.iceberg_generator_user.name
}

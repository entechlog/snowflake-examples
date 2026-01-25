# IAM policy for External Volumes S3 access
resource "aws_iam_policy" "external_volume_s3_policy" {
  name        = "${local.aws_resource_prefix}-ext-volume-s3-policy"
  description = "Policy for Snowflake External Volume S3 access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:DeleteObjectVersion"
        ]
        Resource = "${module.external_volume_bucket.aws_s3_bucket__arn[0]}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketLocation"
        ]
        Resource = module.external_volume_bucket.aws_s3_bucket__arn[0]
        Condition = {
          StringLike = {
            "s3:prefix" = ["*"]
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for Storage Integration Glue access
# Includes read permissions for Snowflake to query Iceberg tables from Glue Catalog
resource "aws_iam_policy" "storage_integration_glue_policy" {
  name        = "${local.aws_resource_prefix}-storage-integration-glue-policy"
  description = "Policy for Snowflake Storage Integration Glue access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
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
      }
    ]
  })

  tags = local.common_tags
}

# Dedicated IAM role for External Volumes
resource "aws_iam_role" "external_volume_role" {
  name = "${local.aws_resource_prefix}-ext-volume-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat(
      # External Volume trust policy
      var.external_volume_aws_external_id != "" ? [{
        Effect = "Allow"
        Principal = {
          AWS = var.external_volume_snowflake_iam_user_arn
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_volume_aws_external_id
          }
        }
      }] : [],
      # Storage Integration trust policy
      var.storage_integration_aws_external_id != "" ? [{
        Effect = "Allow"
        Principal = {
          AWS = var.storage_integration_snowflake_iam_user_arn
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.storage_integration_aws_external_id
          }
        }
      }] : [],
      # Catalog Integration trust policy
      var.catalog_integration_aws_external_id != "" ? [{
        Effect = "Allow"
        Principal = {
          AWS = var.catalog_integration_snowflake_iam_user_arn
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.catalog_integration_aws_external_id
          }
        }
      }] : [],
      # Temporary trust policy if no external IDs provided
      (var.external_volume_aws_external_id == "" && var.storage_integration_aws_external_id == "" && var.catalog_integration_aws_external_id == "") ? [{
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = "sts:AssumeRole"
      }] : []
    )
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "external_volume_s3_attachment" {
  role       = aws_iam_role.external_volume_role.name
  policy_arn = aws_iam_policy.external_volume_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "external_volume_glue_attachment" {
  role       = aws_iam_role.external_volume_role.name
  policy_arn = aws_iam_policy.storage_integration_glue_policy.arn
}
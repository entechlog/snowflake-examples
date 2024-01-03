data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "s3_read_access" {

  statement {
    sid = "AllowReadAccessToS3Bucket"
    actions = ["s3:Get*",
    "s3:List*"]
    resources = [
      "${aws_s3_bucket.app.arn}",
      "${aws_s3_bucket.app.arn}/*"
    ]

  }

}

data "aws_iam_policy_document" "s3_write_access" {

  statement {
    sid = "AllowWriteAccessToS3Bucket"
    actions = ["s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:CreateMultipartUpload",
      "s3:AbortMultipartUpload",
      "s3:ListBucketMultipartUploads"
    ]
    resources = [
      "${aws_s3_bucket.app.arn}",
      "${aws_s3_bucket.app.arn}/*"
    ]
  }

}

data "aws_iam_policy_document" "s3_delete_access" {

  statement {
    sid = "AllowDeleteAccessToS3Bucket"
    actions = ["s3:DeleteObject"
    ]
    resources = [
      "${aws_s3_bucket.app.arn}",
      "${aws_s3_bucket.app.arn}/*"
    ]
  }

}

data "aws_iam_policy_document" "s3_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.mage_user.arn]
    }
  }
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid    = "AllowWriteAccessToS3Bucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${aws_iam_user.mage_user.name}"]
    }

    actions = [
      "s3:Put*",
      "s3:Get*",
      "s3:List*",
      "s3:Delete*",
    ]

    resources = [
      "${aws_s3_bucket.app.arn}",
      "${aws_s3_bucket.app.arn}/*"
    ]
  }

  statement {
    sid = "AllowReadAccessToS3BucketToSnowflake"

    # Defining the principal as the Snowflake IAM role.
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.snowflake.arn]
    }

    # Granting read permissions on the S3 bucket.
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*"
    ]

    effect = "Allow"
    resources = [
      "${aws_s3_bucket.app.arn}",
      "${aws_s3_bucket.app.arn}/*"
    ]
  }

}
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "snowflake_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${local.snowflake__aws_iam_user_arn}"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["${var.snowflake_storage__aws_external_id}"]
    }
  }

  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${local.snowflake__aws_iam_user_arn}"]
    }

    actions = ["sts:AssumeRole"]

    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = ["${var.snowflake_storage__aws_external_id}"]
    }
  }

}

data "aws_iam_policy_document" "s3_read_only_policy_document" {

  statement {
    sid = ""
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.s3_to_snowflake_delivery_role.arn]
    }
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*"
    ]
    effect = "Allow"
    resources = [
      "${aws_s3_bucket.cloudwatch_logs.arn}",
      "${aws_s3_bucket.cloudwatch_logs.arn}/*"
    ]
  }

}

data "aws_iam_policy_document" "sqs_send_message_policy_document" {
  statement {
    effect = "Allow"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["sqs:SendMessage"]
    resources = ["${local.snowflake_pipe__notification_channel}"]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.cloudwatch_logs.arn]
    }
  }
}
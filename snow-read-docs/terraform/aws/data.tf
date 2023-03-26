data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "s3_read_only_policy_document" {

  statement {
    sid = ""
    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.snow_s3_intg.arn]
    }
    actions = [
      "s3:GetObject*",
      "s3:GetBucket*",
      "s3:List*"
    ]
    effect = "Allow"
    resources = [
      "${local.demo_bucket_arn[0]}",
      "${local.demo_bucket_arn[0]}/*"
    ]
  }

}

data "aws_iam_policy_document" "lambda_sns_policy_document" {

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    actions   = ["SNS:Publish"]
    resources = ["${aws_sns_topic.demo_bucket.arn}"]

  }

}
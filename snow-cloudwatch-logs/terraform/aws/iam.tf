resource "aws_iam_role" "cloudwatch_to_firehose_delivery_role" {
  name               = "${local.resource_name_prefix}-cloudwatch-to-firehose-role"
  description        = "IAM role to grant cloudwatch permission to deliver data to firehose"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json
}

resource "aws_iam_policy" "cloudwatch_to_firehose_delivery_policy" {
  name   = "${local.resource_name_prefix}-cloudwatch-to-firehose-delivery-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "firehose:PutRecord",
                "firehose:PutRecordBatch"
            ],
            "Resource": [
                "${aws_kinesis_firehose_delivery_stream.cloudwatch_logs.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudwatch_to_firehose_delivery_policy_attachment" {
  role       = aws_iam_role.cloudwatch_to_firehose_delivery_role.name
  policy_arn = aws_iam_policy.cloudwatch_to_firehose_delivery_policy.arn
}

resource "aws_iam_role" "firehose_to_s3_delivery_role" {
  name               = "${local.resource_name_prefix}-firehose-to-s3-delivery-role"
  description        = "IAM role to grant firehose permission to deliver data to S3"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

resource "aws_iam_policy" "firehose_to_s3_delivery_policy" {
  name   = "${local.resource_name_prefix}-firehose-to-s3-delivery-policy"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents",
                "logs:CreateLogGroup",
                "logs:CreateLogStream"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:AbortMultipartUpload",
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:PutObject"
            ],
            "Resource": [
                "${aws_s3_bucket.cloudwatch_logs.arn}/*",
                "${aws_s3_bucket.cloudwatch_logs.arn}"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "firehose_to_s3_delivery_policy_attachment" {
  role       = aws_iam_role.firehose_to_s3_delivery_role.name
  policy_arn = aws_iam_policy.firehose_to_s3_delivery_policy.arn
}

resource "aws_iam_role" "s3_to_snowflake_delivery_role" {
  name               = "${local.resource_name_prefix}-snow-s3-to-snowflake-role"
  description        = "IAM role used by Snowflake to connect to S3"
  assume_role_policy = data.aws_iam_policy_document.snowflake_assume_role.json
}
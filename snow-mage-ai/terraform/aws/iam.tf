resource "aws_iam_role" "mage_role" {
  name               = "${local.resource_name_prefix}-mage-role"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role.json
}

resource "aws_iam_policy" "mage_role_s3_write" {
  name        = "${local.resource_name_prefix}-mage-role-s3-write-policy"
  description = "S3 write policy for mage role"
  policy      = data.aws_iam_policy_document.s3_write_access.json
}

resource "aws_iam_role_policy_attachment" "mage_role_s3_write_attach" {
  policy_arn = aws_iam_policy.mage_role_s3_write.arn
  role       = aws_iam_role.mage_role.name
}

resource "aws_iam_policy" "mage_role_s3_read" {
  name        = "${local.resource_name_prefix}-mage-role-s3-read-policy"
  description = "S3 read policy for mage role"
  policy      = data.aws_iam_policy_document.s3_read_access.json
}

resource "aws_iam_role_policy_attachment" "mage_role_s3_read_attach" {
  policy_arn = aws_iam_policy.mage_role_s3_read.arn
  role       = aws_iam_role.mage_role.name
}

resource "aws_iam_policy" "mage_role_s3_delete" {
  name        = "${local.resource_name_prefix}-mage-role-s3-delete-policy"
  description = "S3 delete policy for mage role"
  policy      = data.aws_iam_policy_document.s3_delete_access.json
}

resource "aws_iam_role_policy_attachment" "mage_role_s3_delete_attach" {
  policy_arn = aws_iam_policy.mage_role_s3_delete.arn
  role       = aws_iam_role.mage_role.name
}

resource "aws_iam_user" "mage_user" {
  name = "${local.resource_name_prefix}-mage-user"
}

resource "aws_iam_access_key" "mage_user_key" {
  user = aws_iam_user.mage_user.name
}

resource "aws_iam_policy" "allow_assume_mage_role" {
  name        = "AllowAssumeMageRole"
  description = "Allows the user to assume the Mage Role."

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sts:AssumeRole",
        Effect   = "Allow",
        Resource = aws_iam_role.mage_role.arn
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "allow_mage_user_assume_mage_role" {
  user       = aws_iam_user.mage_user.name
  policy_arn = aws_iam_policy.allow_assume_mage_role.arn
}

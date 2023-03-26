data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "lambda_exec_policy" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "kms:Decrypt",
      "textract:StartDocumentTextDetection",
      "textract:GetDocumentTextDetection",
      "textract:AnalyzeDocument",
      "textract:DetectDocumentText",
      "s3:PutObject",
      "s3:GetObjectMetaData",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListMultipartUploadParts",
      "s3:AbortMultipartUpload"
    ]
    resources = [
      "arn:aws:logs:*:*:*",
      "arn:aws:secretsmanager:*",
      "arn:aws:kms:*",
      "arn:aws:s3:::*",
      "*"
    ]
  }
}

resource "null_resource" "copy_files" {

  for_each = toset(var.lambda_function_name)

  provisioner "local-exec" {
    command = "rm -rf ./uploads/lambda/${lower(each.key)}/target && mkdir ./uploads/lambda/${lower(each.key)}/target && cp ./uploads/lambda/${lower(each.key)}/${lower(each.key)}.py -t ./uploads/lambda/${lower(each.key)}/target/ && cp ./uploads/lambda/${lower(each.key)}/requirements.txt -t ./uploads/lambda/${lower(each.key)}/target/ && cp ./uploads/lambda/${lower(each.key)}/log.conf -t ./uploads/lambda/${lower(each.key)}/target/"
  }

  triggers = {
    requirements_file = filemd5("./uploads/lambda/${lower(each.key)}/requirements.txt")
    source_file       = filemd5("./uploads/lambda/${lower(each.key)}/${lower(each.key)}.py")
    log_file          = filemd5("./uploads/lambda/${lower(each.key)}/log.conf")
  }

}

resource "null_resource" "install_dependencies" {

  for_each = toset(var.lambda_function_name)

  provisioner "local-exec" {
    command = "pip install -r ./uploads/lambda/${lower(each.key)}/target/requirements.txt -t ./uploads/lambda/${lower(each.key)}/target"
  }

  triggers = {
    requirements_file = filemd5("./uploads/lambda/${lower(each.key)}/requirements.txt")
    source_file       = filemd5("./uploads/lambda/${lower(each.key)}/${lower(each.key)}.py")
    log_file          = filemd5("./uploads/lambda/${lower(each.key)}/log.conf")
  }

  depends_on = [null_resource.copy_files]
}

data "archive_file" "lambda_function" {

  for_each = toset(var.lambda_function_name)

  type        = "zip"
  source_dir  = "./uploads/lambda/${lower(each.key)}/target/"
  output_path = "./uploads/lambda/${lower(each.key)}.zip"
  excludes    = ["./uploads/lambda/.gitkeep", "__pycache__", "venv"]
  depends_on  = [null_resource.install_dependencies]
}
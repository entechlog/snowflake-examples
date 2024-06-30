resource "aws_secretsmanager_secret" "external_function_secret" {
  for_each = var.secrets

  name       = "/lambda/external_function/${each.key}"
  kms_key_id = var.external_function_kms_key_id
}

resource "aws_secretsmanager_secret_version" "external_function_secret_version" {
  for_each = var.secrets

  secret_id     = aws_secretsmanager_secret.external_function_secret[each.key].id
  secret_string = jsonencode({ (each.key) = each.value })
}

resource "aws_secretsmanager_secret_policy" "external_function_secret_policy" {
  for_each = var.secrets

  secret_arn = aws_secretsmanager_secret.external_function_secret[each.key].arn
  policy     = <<POLICY
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Sid": "AWSLambdaResourcePolicy",
    "Effect" : "Allow",
    "Principal" : {
      "Service" : "lambda.amazonaws.com"
    },
    "Action" : "secretsmanager:getSecretValue",
    "Resource" : "${aws_secretsmanager_secret.external_function_secret[each.key].arn}"
  } ]
}
POLICY
}
// open_weather credentials

resource "aws_secretsmanager_secret" "open_weather" {
  name       = "/lambda/external_function/open_weather_conn"
  kms_key_id = aws_kms_key.kms_lambda.key_id
}

resource "aws_secretsmanager_secret_version" "open_weather_auth" {
  secret_id     = aws_secretsmanager_secret.open_weather.id
  secret_string = jsonencode({ api_key = var.open_weather_api_key })
}

resource "aws_secretsmanager_secret_policy" "open_weather" {
  secret_arn = aws_secretsmanager_secret.open_weather.arn
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
    "Resource" : "${aws_secretsmanager_secret.open_weather.arn}"
  } ]
}
POLICY
}
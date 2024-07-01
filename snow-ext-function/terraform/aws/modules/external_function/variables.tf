## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example : TF_VAR_master_password
## ---------------------------------------------------------------------------------------------------------------------

variable "secrets" {
  type        = map(string)
  description = "Map of different secrets"
  default     = {}
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : optional_var
## ---------------------------------------------------------------------------------------------------------------------

variable "env_code" {
  type        = string
  description = "Environmental code to identify the target environment"
}

variable "resource_name_prefix" {
  type        = string
  description = "Prefix for resource name"
}

variable "snowflake_ext_function_name" {
  description = "Name of the Snowflake external function"
  type        = string
  default     = "demo"
}

variable "aws_lambda_function__environment_variables" {
  description = "Environment variables for the AWS Lambda function"
  type        = map(any)
  default = {
    "key" = "value"
  }
}

variable "lambda_exec_role_arn" {
  description = "ARN of the Lambda execution IAM role"
  type        = string
}

variable "lambda_exec_role_name" {
  description = "Name of the Lambda execution IAM role"
  type        = string
}

variable "snowflake_external_function_role_arn" {
  description = "ARN of the Snowflake external function IAM role"
  type        = string
}

variable "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch IAM role"
  type        = string
}

variable "external_function_kms_key_id" {
  description = "KMS key ID for Snowflake external function"
  type        = string
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------

# These two values are obtained by running the query `DESCRIBE integration <integration-name>;`
# Initially resources should be created with default values only

variable "snowflake_api_aws_iam_user_arn" {
  description = "The AWS IAM user ARN from Snowflake"
  type        = string
  default     = null
}

variable "snowflake_api_aws_external_id" {
  description = "The AWS external ID from Snowflake"
  type        = string
  default     = "12345"
}
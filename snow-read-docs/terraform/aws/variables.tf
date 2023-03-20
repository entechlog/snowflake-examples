## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example : TF_VAR_master_password
## ---------------------------------------------------------------------------------------------------------------------

## ---------------------------------------------------------------------------------------------------------------------
## OPTIONAL PARAMETERS
## These variables have defaults and may be overridden
## Example : optional_var
## ---------------------------------------------------------------------------------------------------------------------

variable "env_code" {
  description = "Environment code to specify the target environment"
  default     = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
  default     = "entechlog"
}

variable "aws_region" {
  description = "AWS region for creating resources"
  default     = "us-east-1"
}

# boolean variable
variable "use_env_code" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = false
}

variable "lambda_function_name" {
  description = "Variable to specifying the list of functions that should be deployed"
  default     = "demo"
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  default     = "demo"
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------

# These two values are obtained by running the query `DESCRIBE integration <integration-name>;`
# Initially resources should be created with default values only

variable "snowflake_storage_aws_iam_user_arn" {
  type        = string
  description = "The AWS IAM user arn from Snowflake"
  default     = null
}

variable "snowflake_storage_aws_external_id" {
  type        = string
  description = "The AWS external ID from Snowflake"
  default     = "12345"
}
## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example : TF_VAR_master_password
## ---------------------------------------------------------------------------------------------------------------------

variable "open_weather_api_key" {
  type        = string
  description = "The API key to access Open Weather services"
  default     = "12345"
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
  default = "demo"
}

variable "aws_lambda_function__environment_variables" {
  type = map(any)
  default = {
    "key" = "value"
  }
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------

# These two values are obtained by running the query `DESCRIBE integration <integration-name>;`
# Initially resources should be created with default values only

variable "snowflake_api_aws_iam_user_arn" {
  type        = string
  description = "The AWS IAM user arn from Snowflake"
  default     = null
}

variable "snowflake_api_aws_external_id" {
  type        = string
  description = "The AWS external ID from Snowflake"
  default     = "12345"
}


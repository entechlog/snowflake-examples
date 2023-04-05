## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example : TF_VAR_master_password
## ---------------------------------------------------------------------------------------------------------------------

## TF_VAR_master_password
variable "TF_VAR_open_weather_api_key" {
  type        = string
  description = "The API key to access open weather api"
  default     = "12345"
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : optional_var
## ---------------------------------------------------------------------------------------------------------------------

variable "env_code" {
  default     = "dev"
  description = "Environmental code to identify the target environment"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
  default     = "entechlog"
}

variable "aws_region" {
  description = "Primary region for all AWS resources"
  default     = "us-east-1"
}

# boolean variable
variable "use_env_code" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = false
}

variable "snowflake_ext_function_name" {
  default = "demo"
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

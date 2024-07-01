## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example : TF_VAR_master_password
## ---------------------------------------------------------------------------------------------------------------------

variable "open_weather_secrets" {
  type        = map(string)
  description = "Map of different secrets for Open Weather"
  default     = {}
}

variable "ipgeolocation_secrets" {
  type        = map(string)
  description = "Map of different secrets for IP Geolocation"
  default     = {}
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : optional_var
## ---------------------------------------------------------------------------------------------------------------------

variable "env_code" {
  description = "Environmental code to identify the target environment"
  type        = string
  default     = "dev"
}

variable "project_code" {
  description = "Project code which will be used as prefix when naming resources"
  type        = string
  default     = "entechlog"
}

variable "aws_region" {
  description = "Primary region for all AWS resources"
  type        = string
  default     = "us-east-1"
}

variable "use_env_code" {
  description = "Toggle on/off the env code in the resource names"
  type        = bool
  default     = false
}

variable "snowflake_ext_function_name" {
  description = "Name of the Snowflake external function"
  type        = string
  default     = "demo"
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

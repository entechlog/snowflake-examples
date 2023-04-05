## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example : TF_VAR_master_password
## ---------------------------------------------------------------------------------------------------------------------

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : optional_var
## ---------------------------------------------------------------------------------------------------------------------

variable "env_code" {
  type        = string
  description = "Environmental code to identify the target environment"
  default     = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
  default     = "entechlog"
}

variable "aws_region" {
  type        = string
  description = "Primary region for all AWS resources"
  default     = "us-east-1"
}

# boolean variable
variable "use_env_code" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = true
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------

# These two values are obtained by running the query `DESCRIBE integration <integration-name>;`
# Initially resources should be created with default values only

variable "snowflake_storage__aws_iam_user_arn" {
  type        = string
  description = "The AWS IAM user arn from Snowflake"
  default     = null
}

variable "snowflake_storage__aws_external_id" {
  type        = string
  description = "The AWS external ID from Snowflake"
  default     = "12345"
}
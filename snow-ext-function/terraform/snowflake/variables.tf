## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example: TF_VAR_master_password
## Snowflake variables required by Snowflake provider
## ---------------------------------------------------------------------------------------------------------------------

variable "snowflake_account" {
  type        = string
  description = "The account name for Snowflake"
}

variable "snowflake_region" {
  type        = string
  description = "The region name for the Snowflake account"
}

variable "snowflake_user" {
  type        = string
  description = "The username for the Snowflake user"
}

variable "snowflake_password" {
  type        = string
  description = "The password for the Snowflake user"
}

variable "snowflake_role" {
  type        = string
  description = "The role for the Snowflake user"
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example: required_var
## ---------------------------------------------------------------------------------------------------------------------

variable "env_code" {
  type        = string
  description = "Environmental code to identify the target environment"
  default     = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as a prefix when naming resources"
  default     = "entechlog"
}

# Boolean variable to toggle the inclusion of env code in resource names
variable "use_env_code" {
  type        = bool
  description = "Toggle on/off the env code in the resource names"
  default     = true
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS VARIABLES REQUIRED TO CREATE AN EXTERNAL FUNCTION
## These values are obtained from the AWS module output
## ---------------------------------------------------------------------------------------------------------------------

variable "aws_iam_role_arn" {
  description = "The ARN of the AWS IAM role"
  type        = string
}

variable "api_integration_enabled" {
  description = "Whether the Snowflake API integration is enabled"
  type        = bool
  default     = true
}

variable "aws_api_gateway_deployment_invoke_url" {
  description = "Map of API Gateway deployment invoke URLs"
  type        = map(string)
}

variable "external_function_api_gateway_url_of_proxy_and_resource" {
  description = "Map of API Gateway deployment proxy and resource URLs"
  type        = map(string)
}

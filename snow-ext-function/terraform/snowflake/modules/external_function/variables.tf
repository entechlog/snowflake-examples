## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------

# Environment code variable
variable "env_code" {
  description = "The environment code (e.g., dev, stg, prd)"
  default     = "dev"
}

# Snowflake variables required to create an external function
variable "snowflake_database_name" {
  description = "The name of the Snowflake database"
  type        = string
}

variable "snowflake_schema_name" {
  description = "The name of the Snowflake schema"
  type        = string
}

variable "snowflake_ext_function_name" {
  description = "The name of the Snowflake external function"
  type        = string
}

variable "snowflake_api_integration_name" {
  description = "The name of the Snowflake API integration"
  type        = string
}

variable "snowflake_function_grant_roles" {
  description = "List of roles to which the function grant should be applied"
  type        = list(string)
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS variables required to create an external function
## These values are obtained from the AWS module output
## ---------------------------------------------------------------------------------------------------------------------

variable "aws_iam_role_arn" {
  description = "The ARN of the AWS IAM role"
  type        = string
}

variable "external_function_api_gateway_url_of_proxy_and_resource" {
  description = "URL of the API Gateway deployment proxy and resource"
  type        = string
}

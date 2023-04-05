## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------

variable "env_code" {
  default = "dev"
}

# Snowflake variables required to create an external function

variable "snowflake_database_name" {
  type = string
}

variable "snowflake_schema_name" {
  type = string
}

variable "snowflake_api_integration_name" {
  type = string
}

variable "snowflake_ext_function_name" {
  default = "demo"
}

variable "snowflake_function_grant__roles" {
  type = list(string)
}

## ---------------------------------------------------------------------------------------------------------------------
# AWS variables required to create an external function
# These values are obtained from the AWS module output
## ---------------------------------------------------------------------------------------------------------------------

variable "aws_api_gateway_deployment__invoke_url" {
  type = list(string)
}

variable "aws_api_gateway_deployment__url_of_proxy_and_resource" {
  type = map(any)
}

variable "aws_iam_role__arn" {
  type = string
}
## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example : TF_VAR_master_password
## Snowflake variables required by snowflake provider
## ---------------------------------------------------------------------------------------------------------------------

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : optional_var
## ---------------------------------------------------------------------------------------------------------------------


## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------

variable "required_snowflake_account" {
  type        = string
  description = "The account name for Snowflake"
}

variable "required_snowflake_region" {
  type        = string
  description = "The region name for Snowflake account"
}

variable "required_snowflake_user" {
  type        = string
  description = "The username for the snowflake user"
}

variable "required_snowflake_password" {
  type        = string
  description = "The password for the snowflake user"
}

variable "required_snowflake_role" {
  type        = string
  description = "The role for the snowflake user"
}

variable "required_env_code" {
  type        = string
  description = "Environmental code to identify the target environment"
}

variable "required_project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
}

variable "required_app_code" {
  type        = string
  description = "Application code which will be used as prefix when naming resources"
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS variables required to create an external function
## These values are obtained from the AWS module output
## ---------------------------------------------------------------------------------------------------------------------

variable "snowflake_storage_integration__storage_allowed_locations" {
  type = list(string)
}

variable "snowflake_storage_integration__storage_blocked_locations" {
  type = list(string)
}

variable "snowflake__aws_role_arn" {
  type = string
}
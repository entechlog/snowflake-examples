## ---------------------------------------------------------------------------------------------------------------------
## ENVIRONMENT VARIABLES
## Define these secrets as environment variables
## Example : TF_VAR_master_password
## Snowflake variables required by snowflake provider
## ---------------------------------------------------------------------------------------------------------------------

variable "snowflake_account" {
  type        = string
  description = "The account name for Snowflake"
}

variable "snowflake_region" {
  type        = string
  description = "The region name for Snowflake account"
}

variable "snowflake_user" {
  type        = string
  description = "The username for the snowflake user"
}

variable "snowflake_password" {
  type        = string
  description = "The password for the snowflake user"
}

variable "snowflake_role" {
  type        = string
  description = "The role for the snowflake user"
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
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

# boolean variable
variable "use_env_code" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = true
}

## ---------------------------------------------------------------------------------------------------------------------
## AWS variables required to create an external function
## These values are obtained from the AWS module output
## ---------------------------------------------------------------------------------------------------------------------

variable "snowflake_storage_integration__storage_allowed_locations" {
  type = list(string)
}

variable "snowflake_storage_integration__storage_aws_role_arn" {
  type = string
}
variable "snowflake_account" {
  type        = string
  description = "The account name for Snowflake"
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

variable "env_code" {
  type        = string
  description = "Environmental code to identify the target environment"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
}

variable "app_code" {
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
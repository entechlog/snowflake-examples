variable "env_code" {
  default = "dev"
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
  default     = false
}

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

variable "snowflake_database_name" {
  type = string
}

variable "snowflake_schema_name" {
  type = string
}

variable "snowflake_storage_integration__name" {
  type = string
}

variable "snowflake_storage_integration__storage_allowed_locations" {
  type = list(string)
}

# These values are obtained from the AWS module output

variable "aws_iam_role__arn" {
  type = string
}
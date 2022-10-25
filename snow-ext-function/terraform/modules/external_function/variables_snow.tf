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

variable "snowflake_api_integration_name" {
  type = string
}
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

variable "terraform_role" {
  type        = string
  description = "The role for the snowflake user"
}

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
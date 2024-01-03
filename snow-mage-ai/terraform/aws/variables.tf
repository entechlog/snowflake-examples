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

variable "optional_aws_region" {
  type        = string
  description = "Primary region for all AWS resources"
  default     = "us-east-1"
}

variable "optional_use_env_code_flag" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = true
}

## ---------------------------------------------------------------------------------------------------------------------
## MODULE PARAMETERS
## These variables are expected to be passed in by the operator
## Example : required_var
## ---------------------------------------------------------------------------------------------------------------------

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
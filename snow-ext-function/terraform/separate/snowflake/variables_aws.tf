variable "env_code" {
  default = "dev"
}

variable "project_code" {
  type        = string
  description = "Project code which will be used as prefix when naming resources"
  default     = "entechlog"
}

variable "aws_region" {
  default = "us-east-1"
}

# boolean variable
variable "use_env_code" {
  type        = bool
  description = "toggle on/off the env code in the resource names"
  default     = false
}

variable "snowflake_ext_function_name" {
  default = "demo"
}

# These values are obtained from the AWS module output

variable "aws_api_gateway_deployment__invoke_url" {
  type = list(string)
}

variable "aws_api_gateway_deployment__url_of_proxy_and_resource" {
  type = map(any)
}

variable "aws_iam_role__arn" {
  type = string
}

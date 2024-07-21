variable "masking_policy_name" {
  type = string
}

variable "masking_policy_database" {
  type = string
}

variable "masking_policy_schema" {
  type = string
}

variable "masking_value_data_type" {
  type = string
}

variable "masking_expression" {
  type = string
}

variable "masking_return_data_type" {
  type = string
}

variable "masking_grants" {
  type = map(any)
}

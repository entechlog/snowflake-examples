variable "name" {
  type = string
}

variable "comment" {
  type = string
}

variable "storage_provider" {
  type = string
}

variable "enabled" {
  type = bool
}

variable "storage_allowed_locations" {
  type = list(string)
}

variable "storage_blocked_locations" {
  type = list(string)
}

variable "storage_aws_role_arn" {
  type = string
}

variable "roles" {
  type = list(string)
}

variable "role_name" {
  type = string
}

variable "role_comment" {
  type = string
}

variable "roles" {
  type = list(string)
}

variable "users" {
  type = list(string)
}
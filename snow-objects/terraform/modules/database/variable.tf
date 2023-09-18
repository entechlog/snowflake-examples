variable "db_name" {
  type = string
}

variable "db_comment" {
  type = string
}

variable "db_grant_roles" {
  type = map(any)
}

variable "schemas" {
  type = list(string)
}

variable "schema_grant" {
  type = map(any)
  default = {}
}

variable "table_grant" {
  type = map(any)
  default = {}
}

variable "schema_privileges_to_role" {
  type = map(any)
  default = {}
}
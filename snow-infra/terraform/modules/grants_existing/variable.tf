variable "db_name" {
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
}

variable "table_grant" {
  type    = map(any)
  default = {}
}

variable "stage_grant" {
  type    = map(any)
  default = {}
}

variable "pipe_grant" {
  type    = map(any)
  default = {}
}

variable "view_grant" {
  type    = map(any)
  default = {}
}
variable "warehouse_name" {
  type        = string
}

variable "warehouse_comment" {
  type        = string
  default     = ""
}

variable "warehouse_size" {
  type        = string
  default     = "XSMALL"
}

variable "warehouse_auto_resume" {
  type        = bool
  default     = true
}

variable "warehouse_auto_suspend" {
  type        = number
  default     = 60
}

variable "warehouse_initially_suspended" {
  type        = bool
  default     = true
}

variable "warehouse_max_cluster_count" {
  type        = number
  default     = 1
}

variable "warehouse_min_cluster_count" {
  type        = number
  default     = 1
}

variable "warehouse_scaling_policy" {
  type        = string
  default     = "ECONOMY"
}

variable "warehouse_grant_roles" {
  type        = map(any)
}

variable "warehouse_grant_with_grant_option" {
  type        = bool
  default     = false
}
variable "warehouse_name" {
  type = string
}

variable "warehouse_comment" {
  type    = string
  default = ""
}

variable "warehouse_size" {
  type    = string
  default = "XSMALL"
}

variable "warehouse_auto_resume" {
  type    = bool
  default = true
}

variable "warehouse_auto_suspend" {
  type    = number
  default = 60
}

variable "warehouse_initially_suspended" {
  type    = bool
  default = true
}

variable "warehouse_max_cluster_count" {
  type    = number
  default = 3
}

variable "warehouse_min_cluster_count" {
  type    = number
  default = 1
}

variable "warehouse_scaling_policy" {
  type    = string
  default = "ECONOMY"
}

variable "warehouse_grant" {
  type    = map(any)
  default = {}
}

variable "warehouse_grant_with_grant_option" {
  type    = bool
  default = false
}

variable "resource_monitor_credit_quota" {
  type    = number
  default = 25
}

variable "resource_monitor_frequency" {
  type    = string
  default = "DAILY"
}

variable "resource_monitor_start_timestamp" {
  type    = string
  default = "IMMEDIATELY"
}

variable "resource_monitor_notify_triggers" {
  type    = list(number)
  default = [80]
}

variable "resource_monitor_suspend_triggers" {
  type    = list(number)
  default = [100]
}

variable "resource_monitor_suspend_immediate_triggers" {
  type    = list(number)
  default = [150]
}
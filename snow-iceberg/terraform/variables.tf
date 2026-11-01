# Environment and project configuration
variable "use_env_code" {
  type        = bool
  description = "Toggle on/off the env code in the resource names"
  default     = false
}

variable "env_code" {
  description = "Environment code (3-character standard: DEV, TST, STG, PRD)"
  type        = string
  default     = "DEV"
  validation {
    condition     = contains(["DEV", "TST", "STG", "PRD"], upper(var.env_code))
    error_message = "Environment code must be one of: DEV, TST, STG, PRD."
  }
}

variable "project_code" {
  type        = string
  description = "Project code used as prefix for resource names"
  default     = "ENTECHLOG"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# Snowflake configuration
variable "snowflake_organization_name" {
  description = "Snowflake organization name"
  type        = string
  sensitive   = true
}

variable "snowflake_account_name" {
  description = "Snowflake account name"
  type        = string
  sensitive   = true
}

variable "snowflake_username" {
  description = "Snowflake username"
  type        = string
}

variable "snowflake_password" {
  type        = string
  description = "Snowflake user password"
  sensitive   = true
}

variable "snowflake_role" {
  description = "Snowflake role"
  type        = string
  default     = "ACCOUNTADMIN"
}

# External Volume IAM configuration (for external_volumes_*.tf files)
variable "external_volume_snowflake_iam_user_arn" {
  description = "Snowflake IAM user ARN for External Volume (from DESC EXTERNAL VOLUME)"
  type        = string
  default     = ""
}

variable "external_volume_aws_external_id" {
  description = "External Volume external ID (from DESC EXTERNAL VOLUME)"
  type        = string
  default     = ""
}

# Storage Integration IAM configuration (for external_volumes_*.tf files)
variable "storage_integration_snowflake_iam_user_arn" {
  description = "Snowflake IAM user ARN for Storage Integration (from DESC STORAGE INTEGRATION)"
  type        = string
  default     = ""
}

variable "storage_integration_aws_external_id" {
  description = "Storage Integration external ID (from DESC STORAGE INTEGRATION)"
  type        = string
  default     = ""
}

# Catalog Integration IAM configuration
variable "catalog_integration_snowflake_iam_user_arn" {
  description = "Snowflake IAM user ARN for Catalog Integration (from DESC CATALOG INTEGRATION - GLUE_AWS_IAM_USER_ARN)"
  type        = string
  default     = ""
}

variable "catalog_integration_aws_external_id" {
  description = "Catalog Integration external ID (from DESC CATALOG INTEGRATION - GLUE_AWS_EXTERNAL_ID)"
  type        = string
  default     = ""
}

variable "snowflake_warehouse" {
  description = "Snowflake warehouse for compute operations"
  type        = string
  default     = "COMPUTE_WH"
}

variable "create_iceberg_tables" {
  description = "Create Snowflake Iceberg tables (set false for first apply, true after PyIceberg generator creates tables)"
  type        = bool
  default     = false
}

variable "glue_default_catalog_namespace" {
  description = "Default Glue catalog namespace for Snowflake catalog integration (must match a key in iceberg_tables)"
  type        = string
  default     = "faker"
}

# Iceberg tables configuration
# Key = source system name (e.g., 'faker', 'hubspot', 'billing_db')
# Value = list of table names from that source
variable "iceberg_tables" {
  description = <<-EOT
    Map of source systems to their table names for Iceberg tables.
    Source naming convention:
    - Use actual source system name (e.g., 'hubspot', 'salesforce', 'stripe')
    - For internal apps/DBs, use descriptive name (e.g., 'billing_db', 'customer_portal_db', 'inventory_db')
    - NOT technology name (postgres, mysql) or domain (sales, marketing)
  EOT
  type        = map(list(string))
  default = {
    faker = [
      "customers",
      "orders",
      "products",
      "event_logs"
    ]
    datagen = [
      "customers"
    ]
    # slingdata excluded - iceberg-go manifest incompatible with Snowflake (works with Athena)
    # slingdata = [
    #   "customers",
    #   "orders"
    # ]
  }
}

# Terraform resource timing
variable "resource_creation_wait_time" {
  description = "Wait time for resource creation dependencies (e.g., '30s', '1m')"
  type        = string
  default     = "30s"
}

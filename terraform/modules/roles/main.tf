terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.33.1"
    }
  }
}

resource "snowflake_role" "role" {
  name    = var.role_name
  comment = var.role_comment
}

resource "snowflake_role_grants" "grants" {
  role_name = snowflake_role.role.name
  roles     = var.roles
  users     = var.users
}

output "role" {
  value = snowflake_role.role
}
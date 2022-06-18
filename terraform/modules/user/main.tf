terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.35.0"
    }
  }
}

//***************************************************************************//
// Create Snowflake User
//***************************************************************************//

resource "snowflake_user" "user" {

  for_each = var.user_map

  name         = lower(each.key)
  login_name   = lower(each.key)
  disabled     = false
  display_name = "${title(each.value.first_name)} ${title(each.value.last_name)}"
  email        = lookup(each.value, "email", "NONE") == "NONE" ? "" : each.value.email
  first_name   = title(each.value.first_name)
  last_name    = title(each.value.last_name)

  default_warehouse = lookup(each.value, "default_warehouse", "NONE") == "NONE" ? "" : each.value.default_warehouse
  default_role      = "PUBLIC"

  must_change_password = false
}

// Output block starts here

output "user" {
  value = snowflake_user.user
}
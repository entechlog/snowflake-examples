terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.33.1"
    }
  }
}

//***************************************************************************//
// Create Snowflake User
//***************************************************************************//

resource "snowflake_user" "user" {

  for_each = var.user_map

  name         = upper(each.key)
  login_name   = upper(each.key)
  disabled     = false
  display_name = "${title(each.value.first_name)} ${title(each.value.last_name)}"
  email        = each.value.email
  first_name   = title(each.value.first_name)
  last_name    = title(each.value.last_name)

  default_warehouse = lookup(each.value, "default_warehouse", "NONE") == "NONE" ? "DEFAULT_WH" : each.value.default_warehouse
  default_role      = "NONE"

  must_change_password = false
}

output "user" {
  value = snowflake_user.user
}
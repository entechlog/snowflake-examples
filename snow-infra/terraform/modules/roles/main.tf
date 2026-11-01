resource "snowflake_account_role" "role" {
  name    = var.role_name
  comment = var.role_comment
}

resource "snowflake_grant_account_role" "role_grants" {
  for_each  = toset(var.users)
  role_name = var.role_name
  user_name = each.value

  depends_on = [snowflake_account_role.role]
}

resource "snowflake_grant_account_role" "parent_role_grants" {
  for_each         = toset(var.roles)
  role_name        = snowflake_account_role.role.name
  parent_role_name = each.value

  depends_on = [snowflake_account_role.role]
}
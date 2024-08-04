//***************************************************************************//
// Create Snowflake user
//***************************************************************************//

resource "snowflake_user" "demo_user" {
  name         = lower("DEMO_USER")
  login_name   = "DEMO_USER"
  comment      = "Snowflake user account for demo"
  password     = "demouser"
  disabled     = false
  display_name = "Demo User"
  email        = "demo_user@example.com"
  first_name   = "Demo"
  last_name    = "User"

  default_role = snowflake_account_role.demo_role.name

  must_change_password = false
}

//***************************************************************************//
// Create Snowflake role
//***************************************************************************//

resource "snowflake_account_role" "demo_role" {
  name    = "${upper(local.resource_name_prefix)}_DEMO_ROLE"
  comment = "Snowflake role used for demos"
}

//***************************************************************************//
// Create Snowflake role grants
//***************************************************************************//

resource "snowflake_grant_account_role" "demo_role_grant" {

  role_name = snowflake_account_role.demo_role.name
  user_name = snowflake_user.demo_user.name

  depends_on = [snowflake_account_role.demo_role]
}
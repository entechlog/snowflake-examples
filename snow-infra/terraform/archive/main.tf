//***************************************************************************//
// Create Snowflake user
//***************************************************************************//

// Managing Snowflake users using Terraform will put the password in the terraform state file
// This is not recommended method for creating users, rather use more secure options like SCIM
// https://docs.snowflake.com/en/user-guide/scim.html

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

  default_warehouse = snowflake_warehouse.dev_entechlog_demo_wh_s.name
  default_role      = terraform_role.entechlog_demo_role.name

  must_change_password = false
}

//***************************************************************************//
// Create Snowflake role
//***************************************************************************//

resource "terraform_role" "entechlog_demo_role" {
  name    = "ENTECHLOG_DEMO_ROLE"
  comment = "Snowflake role used for demos"
}

//***************************************************************************//
// Create Snowflake role grants
//***************************************************************************//

resource "terraform_role_grants" "entechlog_demo_role_grant" {
  role_name = terraform_role.entechlog_demo_role.name
  roles     = ["SYSADMIN"]
  users = [
    "${snowflake_user.demo_user.name}"
  ]
}

//***************************************************************************//
// Create Snowflake database
//***************************************************************************//

resource "snowflake_database" "dev_entechlog_demo_db" {
  name    = "DEV_ENTECHLOG_DEMO_DB"
  comment = "Database to store the demo data"
}

//***************************************************************************//
// Create Snowflake warehouse
//***************************************************************************//

resource "snowflake_warehouse" "dev_entechlog_demo_wh_s" {
  name                = "DEV_ENTECHLOG_DEMO_WH_S"
  comment             = "Small warehouse used for demos"
  warehouse_size      = "small"
  auto_resume         = true
  auto_suspend        = 10
  initially_suspended = true
  max_cluster_count   = 1
  min_cluster_count   = 1
  scaling_policy      = "ECONOMY" //Should be in CAPS
}

//***************************************************************************//
// Create Snowflake warehouse grants
//***************************************************************************//

resource "snowflake_warehouse_grant" "dev_entechlog_demo_wh_s_grant" {
  warehouse_name = snowflake_warehouse.dev_entechlog_demo_wh_s.name
  privilege      = "USAGE"

  roles = [
    "${terraform_role.entechlog_demo_role.name}",
  ]

  with_grant_option = false
}
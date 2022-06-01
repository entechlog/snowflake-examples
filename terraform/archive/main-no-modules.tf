terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.33.1"
    }
  }
}

provider "snowflake" {
  account  = var.snowflake_account
  region   = var.snowflake_region
  username = var.snowflake_user
  password = var.snowflake_password
  role = var.snowflake_role
}

//***************************************************************************//
// Create Snowflake database
//***************************************************************************//

resource "snowflake_database" "dev_entechlog_raw" {
  name    = "DEV_ENTECHLOG_RAW"
  comment = "TF template to create database to store the ingested RAW data"
}

//***************************************************************************//
// Create Snowflake user
//***************************************************************************//

// Managing Snowflake users using Terraform will put the password in the terraform state file
// This is not recommended method for creating users, rather use more secure options like SCIM
// https://docs.snowflake.com/en/user-guide/scim.html

resource "snowflake_user" "dbt_user" {
  name         = "DBT_USER"
  login_name   = "DBT_USER"
  comment      = "Snowflake account for dbt"
  password     = "dbtuser"
  disabled     = false
  display_name = "dbt User"
  email        = "user@example.com"
  first_name   = "dbt"
  last_name    = "User"

  default_warehouse = snowflake_warehouse.dev_entechlog_dbt_wh_s.name
  default_role      = snowflake_role.entechlog_dbt.name

  must_change_password = false
}

//***************************************************************************//
// Create Snowflake role
//***************************************************************************//

resource "snowflake_role" "entechlog_dbt" {
  name    = "ENTECHLOG_DBT"
  comment = "Snowflake role used by dbt"
}

//***************************************************************************//
// Create Snowflake role grants
//***************************************************************************//

resource "snowflake_role_grants" "entechlog_dbt_grant" {
  role_name = snowflake_role.entechlog_dbt.name

  roles = []

  users = [
    "${snowflake_user.dbt_user.name}"
  ]
}

//***************************************************************************//
// Create Snowflake warehouse
//***************************************************************************//

resource "snowflake_warehouse" "dev_entechlog_dbt_wh_s" {
  name                = "DEV_ENTECHLOG_DBT_WH_S"
  comment             = "Small warehouse used for dbt"
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

resource "snowflake_warehouse_grant" "dev_entechlog_dbt_wh_s_grant" {
  warehouse_name = snowflake_warehouse.dev_entechlog_dbt_wh_s.name
  privilege      = "MODIFY"

  roles = [
    "${snowflake_role.entechlog_dbt.name}",
  ]

  with_grant_option = false
}
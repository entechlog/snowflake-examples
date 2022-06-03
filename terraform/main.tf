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
  role     = var.snowflake_role
}

//***************************************************************************//
// Create Snowflake user
//***************************************************************************//

// Managing Snowflake users using Terraform will put the password in the terraform state file
// This is not recommended method for creating users, rather use more secure options like SCIM
// https://docs.snowflake.com/en/user-guide/scim.html

resource "snowflake_user" "demo_user" {
  name         = "Demo User"
  login_name   = "DEMO_USER"
  comment      = "Snowflake user account for demo"
  password     = "demouser"
  disabled     = false
  display_name = "Demo User"
  email        = "demo_user@example.com"
  first_name   = "Demo"
  last_name    = "User"

  default_warehouse = snowflake_warehouse.dev_entechlog_demo_wh_s.name
  default_role      = snowflake_role.entechlog_demo_role.name

  must_change_password = false
}

//***************************************************************************//
// Create Snowflake role
//***************************************************************************//

resource "snowflake_role" "entechlog_demo_role" {
  name    = "ENTECHLOG_DEMO_ROLE"
  comment = "Snowflake role used for demos"
}

//***************************************************************************//
// Create Snowflake role grants
//***************************************************************************//

resource "snowflake_role_grants" "entechlog_demo_role_grant" {
  role_name = snowflake_role.entechlog_demo_role.name
  roles     = []
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
    "${snowflake_role.entechlog_demo_role.name}",
  ]

  with_grant_option = false
}

//***************************************************************************//
// Create Snowflake user using modules
//***************************************************************************//

module "all_users" {
  source = "./modules/user"
  user_map = {
    "dev_entechlog_dbt_user" : { "first_name" = "datastage", "last_name" = "User", "email" = "dev_entechlog_dbt_user@example.com", "default_warehouse" = "DATASTAGE_WH", "default_role" = "DATASTAGE_ROLE" },
    "dev_entechlog_atlan_user" : { "first_name" = "atlan", "last_name" = "User", "email" = "dev_entechlog_atlan_user@example.com" }
    "dev_entechlog_kafka_user" : { "first_name" = "Kafka", "last_name" = "User", "email" = "dev_entechlog_kafka_user@example.com" }
  }
}

output "all_users" {
  value     = module.all_users
  sensitive = true
}

resource "snowflake_role" "entechlog_dbt_role" {
  name    = "ENTECHLOG_DBT_ROLE"
  comment = "Snowflake role used by dbt"
}

resource "snowflake_role_grants" "entechlog_dbt_role_grant" {
  role_name = snowflake_role.entechlog_dbt_role.name
  roles     = []
  users = [
    "${module.all_users.user.dev_entechlog_dbt_user.name}"
  ]
}

resource "snowflake_role" "entechlog_atlan_role" {
  name    = "ENTECHLOG_ATLAN_ROLE"
  comment = "Snowflake role used by Atlan"
}

resource "snowflake_role_grants" "entechlog_atlan_role_grant" {
  role_name = snowflake_role.entechlog_atlan_role.name
  roles     = []
  users = [
    "${module.all_users.user.dev_entechlog_atlan_user.name}"
  ]
}

//***************************************************************************//
// Create Snowflake warehouse using modules
//***************************************************************************//

module "dev_entechlog_dbt_wh_xs" {
  source         = "./modules/warehouse"
  warehouse_name = "DEV_ENTECHLOG_DBT_WH_XS"
  warehouse_size = "XSMALL"
  warehouse_grant_roles = {
    "OWNERSHIP" = [var.snowflake_role]
    "USAGE"     = [snowflake_role.entechlog_dbt_role.name]
  }
}


//***************************************************************************//
// Create Snowflake database and schema using modules
//***************************************************************************//

module "dev_entechlog_raw_db" {
  source = "./modules/database"

  db_name    = "DEV_ENTECHLOG_RAW_DB"
  db_comment = "Database to store the ingested RAW data"

  db_grant_roles = {
    "OWNERSHIP" = [var.snowflake_role]
    "USAGE"     = [snowflake_role.entechlog_dbt_role.name]
    "USAGE"     = ["SYSADMIN"]
  }

  schemas = ["FACEBOOK", "GOOGLE"]
  schema_grant = {
    "FACEBOOK CREATE TABLE" = { "roles" = [snowflake_role.entechlog_dbt_role.name] },
    "FACEBOOK CREATE VIEW"  = { "roles" = [snowflake_role.entechlog_dbt_role.name] },
    "GOOGLE CREATE TABLE"   = { "roles" = [snowflake_role.entechlog_dbt_role.name] },
    "GOOGLE CREATE VIEW"    = { "roles" = [snowflake_role.entechlog_dbt_role.name] }
  }
}

output "dev_entechlog_raw_db" {
  value = module.dev_entechlog_raw_db

}

//***************************************************************************//
// Create roles using modules
//***************************************************************************//

module "entechlog_kafka_role" {
  source       = "./modules/roles"
  role_name    = "ENTECHLOG_KAFKA_ROLE"
  role_comment = "Snowflake role used by Kafka"

  roles = []
  users = [
    "${module.all_users.user.dev_entechlog_kafka_user.name}"
  ]
}
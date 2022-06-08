terraform {
  backend "remote" {
    organization = "entechlog"
    workspaces {
      name = "snowflake-examples"
    }
  }
}

terraform {
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "0.35.0"
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
// Create Snowflake user using modules
//***************************************************************************//

module "all_users" {
  source = "./user"
  user_map = {
    "entechlog_dbt_user" : { "first_name" = "datastage", "last_name" = "User", "email" = "${lower(var.env_code)}_entechlog_dbt_user@example.com", "default_warehouse" = "DATASTAGE_WH", "default_role" = "DATASTAGE_ROLE" },
    "entechlog_atlan_user" : { "first_name" = "atlan", "last_name" = "User", "email" = "${lower(var.env_code)}_entechlog_atlan_user@example.com" }
    "entechlog_kafka_user" : { "first_name" = "Kafka", "last_name" = "User", "email" = "${lower(var.env_code)}_entechlog_kafka_user@example.com" }
  }
}

output "all_users" {
  value     = module.all_users
  sensitive = true
}

//***************************************************************************//
// Create roles using modules
//***************************************************************************//

module "entechlog_dbt_role" {
  source       = "./roles"
  role_name    = "ENTECHLOG_DBT_ROLE"
  role_comment = "Snowflake role used by dbt"

  roles = ["SYSADMIN"]
  users = [
    "${module.all_users.user.entechlog_dbt_user.name}"
  ]
}

module "entechlog_atlan_role" {
  source       = "./roles"
  role_name    = "ENTECHLOG_ATLAN_ROLE"
  role_comment = "Snowflake role used by Atlan"

  roles = ["SYSADMIN"]
  users = [
    "${module.all_users.user.entechlog_atlan_user.name}"
  ]
}

module "entechlog_kafka_role" {
  source       = "./roles"
  role_name    = "ENTECHLOG_KAFKA_ROLE"
  role_comment = "Snowflake role used by Kafka"

  roles = ["SYSADMIN"]
  users = [
    "${module.all_users.user.entechlog_kafka_user.name}"
  ]
}

module "entechlog_analyst_role" {
  source       = "./roles"
  role_name    = "ENTECHLOG_ANALYST_ROLE"
  role_comment = "Snowflake role used by Analyst"

  roles = ["SYSADMIN"]
  users = ["admin@entechlog.com"]
}

//***************************************************************************//
// Create Snowflake warehouse using modules
//***************************************************************************//

module "entechlog_dbt_wh_xs" {
  source         = "./warehouse"
  warehouse_name = "${upper(var.env_code)}_ENTECHLOG_DBT_WH_XS"
  warehouse_size = "XSMALL"
  warehouse_grant_roles = {
    "OWNERSHIP" = [var.snowflake_role]
    "USAGE"     = [module.entechlog_dbt_role.role.name]
  }
}

//***************************************************************************//
// Create Snowflake database and schema using modules
//***************************************************************************//

module "entechlog_raw_db" {
  source = "./database"

  db_name    = "${upper(var.env_code)}_ENTECHLOG_RAW_DB"
  db_comment = "Database to store the ingested RAW data"

  db_grant_roles = {
    "OWNERSHIP" = [var.snowflake_role]
    "USAGE"     = [module.entechlog_dbt_role.role.name]
    "USAGE"     = ["SYSADMIN"]
  }

  schemas = ["FACEBOOK", "GOOGLE", "COMPLIANCE"]
  schema_grant = {
    "FACEBOOK USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, module.entechlog_atlan_role.role.name, module.entechlog_kafka_role.role.name] },
    "GOOGLE USAGE"          = { "roles" = [module.entechlog_dbt_role.role.name, module.entechlog_atlan_role.role.name, module.entechlog_kafka_role.role.name] },
    "FACEBOOK CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
    "FACEBOOK CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] },
    "GOOGLE CREATE TABLE"   = { "roles" = [module.entechlog_dbt_role.role.name] },
    "GOOGLE CREATE VIEW"    = { "roles" = [module.entechlog_dbt_role.role.name] }
  }

  table_grant = {
    "FACEBOOK SELECT" = { "roles" = [module.entechlog_atlan_role.role.name] },
    "GOOGLE SELECT"   = { "roles" = [module.entechlog_atlan_role.role.name] }
  }

}

//***************************************************************************//
// Create masking policy using modules
//***************************************************************************//

module "mp_encrypt_email" {
  source                   = "./masking-policy"
  masking_policy_name      = "MP_ENCRYPT_EMAIL"
  masking_policy_database  = module.entechlog_raw_db.database.name
  masking_policy_schema    = "COMPLIANCE"
  masking_value_data_type  = "VARCHAR"
  masking_expression       = "CASE WHEN CURRENT_ROLE() IN ('SYSADMIN') THEN val ELSE '**********' END"
  masking_return_data_type = "VARCHAR(16777216)"

  masking_grants = {
    "OWNERSHIP" = [var.snowflake_role]
    "APPLY"     = [module.entechlog_dbt_role.role.name]
  }
}

//***************************************************************************//
// Create storage integration using modules
//***************************************************************************//

module "entechlog_str_s3_intg" {
  source                    = "./storage-integration"
  name                      = "ENTECHLOG_STR_S3_INTG"
  comment                   = ""
  storage_provider          = "S3"
  enabled                   = true
  storage_allowed_locations = ["s3://entechlog-demo/kafka-snowpipe-demo/"]
  storage_blocked_locations = ["s3://entechlog-demo/secure/"]
  storage_aws_role_arn      = "arn:aws:iam::001234567890:role/myrole"
  roles                     = [module.entechlog_dbt_role.role.name]
}

// Output block starts here

output "entechlog_raw_db" {
  value = module.entechlog_raw_db

}
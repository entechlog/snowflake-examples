terraform {
  backend "remote" {
    organization = "entechlog"
    workspaces {
      prefix = "snowflake-"
    }
  }
}

locals {
  enable_resource_mapping = {
    snowflake-dev = 0
    snowflake-stg = 0
    snowflake-prd = 1
  }
  enable_resource_flag = local.enable_resource_mapping[terraform.workspace]
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
  count  = local.enable_resource_flag
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
  count        = local.enable_resource_flag
  role_name    = "ENTECHLOG_DBT_ROLE"
  role_comment = "Snowflake role used by dbt"

  roles = ["SYSADMIN"]
  users = [try(module.all_users[0].user.entechlog_dbt_user.name, "")]
}

module "entechlog_atlan_role" {
  source       = "./roles"
  count        = local.enable_resource_flag
  role_name    = "ENTECHLOG_ATLAN_ROLE"
  role_comment = "Snowflake role used by Atlan"

  roles = ["SYSADMIN"]
  users = [try(module.all_users[0].user.entechlog_atlan_user.name, "")]
}

module "entechlog_kafka_role" {
  source       = "./roles"
  count        = local.enable_resource_flag
  role_name    = "ENTECHLOG_KAFKA_ROLE"
  role_comment = "Snowflake role used by Kafka"

  roles = ["SYSADMIN"]
  users = [try(module.all_users[0].user.entechlog_kafka_user.name, "")]
}

module "entechlog_analyst_role" {
  source       = "./roles"
  count        = local.enable_resource_flag
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
    "USAGE"     = [try(module.entechlog_dbt_role[0].role.name, "")]
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
    "USAGE"     = [try(module.entechlog_dbt_role[0].role.name, "")]
    "USAGE"     = ["SYSADMIN"]
  }

  schemas = ["FACEBOOK", "GOOGLE", "COMPLIANCE"]
  schema_grant = {
    "FACEBOOK OWNERSHIP"    = { "roles" = [try(module.entechlog_dbt_role[0].role.name, "")] },
    "GOOGLE OWNERSHIP"      = { "roles" = [try(module.entechlog_dbt_role[0].role.name, "")] },
    "FACEBOOK USAGE"        = { "roles" = [try(module.entechlog_dbt_role[0].role.name, ""), try(module.entechlog_atlan_role[0].role.name, ""), try(module.entechlog_kafka_role[0].role.name, "")] },
    "GOOGLE USAGE"          = { "roles" = [try(module.entechlog_dbt_role[0].role.name, ""), try(module.entechlog_atlan_role[0].role.name, ""), try(module.entechlog_kafka_role[0].role.name, "")] },
    "FACEBOOK CREATE TABLE" = { "roles" = [try(module.entechlog_dbt_role[0].role.name, "")] },
    "FACEBOOK CREATE VIEW"  = { "roles" = [try(module.entechlog_dbt_role[0].role.name, "")] },
    "GOOGLE CREATE TABLE"   = { "roles" = [try(module.entechlog_dbt_role[0].role.name, "")] },
    "GOOGLE CREATE VIEW"    = { "roles" = [try(module.entechlog_dbt_role[0].role.name, "")] }
  }

  table_grant = {
    "FACEBOOK SELECT" = { "roles" = [try(module.entechlog_atlan_role[0].role.name, "")] },
    "GOOGLE SELECT"   = { "roles" = [try(module.entechlog_atlan_role[0].role.name, "")] }
  }

}

//***************************************************************************//
// Create masking policy using modules
//***************************************************************************//

module "mp_encrypt_email" {
  source                   = "./masking-policy"
  count                    = local.enable_resource_flag
  masking_policy_name      = "MP_ENCRYPT_EMAIL"
  masking_policy_database  = module.entechlog_raw_db.database.name
  masking_policy_schema    = module.entechlog_raw_db.schema["COMPLIANCE"].name
  masking_value_data_type  = "VARCHAR"
  masking_expression       = "CASE WHEN CURRENT_ROLE() IN ('SYSADMIN') THEN val ELSE '**********' END"
  masking_return_data_type = "VARCHAR(16777216)"

  masking_grants = {
    "OWNERSHIP" = [var.snowflake_role]
    "APPLY"     = [try(module.entechlog_dbt_role[0].role.name, "")]
  }
  
}

//***************************************************************************//
// Create storage integration using modules
//***************************************************************************//

module "entechlog_str_s3_intg" {
  source                    = "./storage-integration"
  count                     = local.enable_resource_flag
  name                      = "ENTECHLOG_STR_S3_INTG"
  comment                   = ""
  storage_provider          = "S3"
  enabled                   = true
  storage_allowed_locations = ["s3://entechlog-demo/kafka-snowpipe-demo/"]
  storage_blocked_locations = ["s3://entechlog-demo/secure/"]
  storage_aws_role_arn      = "arn:aws:iam::001234567890:role/myrole"
  roles                     = [try(module.entechlog_dbt_role[0].role.name, "")]
}

// Output block starts here

output "entechlog_raw_db" {
  value = module.entechlog_raw_db

}
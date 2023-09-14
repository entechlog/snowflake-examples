//***************************************************************************//
// Create Snowflake warehouse using modules
//***************************************************************************//

module "dbt_wh_xs" {
  source                 = "../../../snow-objects/terraform/modules/warehouse"
  warehouse_name         = "${upper(local.resource_prefix_with_env)}_DBT_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30
  warehouse_grant_roles = {
    "OWNERSHIP" = ["SYSADMIN"]
    "MODIFY"    = [var.required_snowflake_role]
    "USAGE"     = (upper(var.required_env_code) == "DEV" || upper(var.required_env_code) == "TST" ? [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] : [module.dbt_role.role.name])
    "MONITOR"   = [module.dbt_role.role.name]
  }

  depends_on = [module.dbt_role.role, module.developer_role.role]
}

module "query_wh_xs" {
  source                 = "../../../snow-objects/terraform/modules/warehouse"
  count                  = local.enable_in_dev_flag
  warehouse_name         = "ALL_${upper(local.resource_prefix_without_env)}_QUERY_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30
  warehouse_grant_roles = {
    "OWNERSHIP" = ["SYSADMIN"]
    "MODIFY"    = [var.required_snowflake_role]
    "USAGE"     = [module.analyst_role[0].role.name, module.developer_role[0].role.name]
    "MONITOR"   = [module.dbt_role.role.name]
  }

  depends_on = [module.analyst_role.role, module.developer_role.role]
}

//***************************************************************************//
// Create Snowflake database and schema using modules
//***************************************************************************//

// RAW Layer

module "raw_db" {
  source = "../../../snow-objects/terraform/modules/database"

  db_name    = "${upper(local.resource_prefix_with_env)}_RAW_DB"
  db_comment = "Database to store the ingested RAW data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.required_snowflake_role]
    "USAGE"         = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"]
  }

  schemas = ["SEED", "CRICSHEET"]

  /* https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html#schema-privileges */
  schema_grant = {
    "SEED OWNERSHIP"                  = { "roles" = ["SYSADMIN"] },
    "SEED USAGE"                      = { "roles" = [var.required_snowflake_role, module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] },
    "SEED CREATE TABLE"               = { "roles" = [module.dbt_role.role.name] },
    "SEED CREATE VIEW"                = { "roles" = [module.dbt_role.role.name] },
    "SEED CREATE STAGE"               = { "roles" = [module.dbt_role.role.name] },
    "CRICSHEET OWNERSHIP"             = { "roles" = ["SYSADMIN"] },
    "CRICSHEET USAGE"                 = { "roles" = [var.required_snowflake_role, module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] },
    "CRICSHEET CREATE TABLE"          = { "roles" = [module.dbt_role.role.name] },
    "CRICSHEET CREATE EXTERNAL TABLE" = { "roles" = [module.dbt_role.role.name] },
    "CRICSHEET CREATE VIEW"           = { "roles" = [module.dbt_role.role.name] },
    "CRICSHEET CREATE STAGE"          = { "roles" = [var.required_snowflake_role, module.dbt_role.role.name] },
    "CRICSHEET CREATE FILE FORMAT"    = { "roles" = [var.required_snowflake_role] }
  }

  table_grant = {
    "SEED SELECT"      = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] }
    "CRICSHEET SELECT" = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] }
  }

  depends_on = [module.dbt_role.role]
}

// Staging Layer, No user access other than dbt roles and developer role

module "prep_db" {
  source = "../../../snow-objects/terraform/modules/database"

  db_name    = "${upper(local.resource_prefix_with_env)}_PREP_DB"
  db_comment = "Database to store the standardized data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.required_snowflake_role, module.dbt_role.role.name]
    "USAGE"         = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"]
  }

  schemas = ["DIM", "FACT", "UTIL"]

  schema_grant = {
    "DIM OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "DIM USAGE"        = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] },
    "DIM CREATE TABLE" = { "roles" = [module.dbt_role.role.name] },
    "DIM CREATE VIEW"  = { "roles" = [module.dbt_role.role.name] },

    "FACT OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "FACT USAGE"        = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] },
    "FACT CREATE TABLE" = { "roles" = [module.dbt_role.role.name] },
    "FACT CREATE VIEW"  = { "roles" = [module.dbt_role.role.name] }

    "UTIL OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "UTIL USAGE"        = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] },
    "UTIL CREATE TABLE" = { "roles" = [module.dbt_role.role.name] },
    "UTIL CREATE VIEW"  = { "roles" = [module.dbt_role.role.name] }
  }

  table_grant = {
    "DIM SELECT"  = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] },
    "FACT SELECT" = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] },
    "UTIL SELECT" = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE"] }
  }

  depends_on = [module.dbt_role.role, module.developer_role.role]
}

// DW Layer, This is the only layer an end user should have access

module "dw_db" {
  source = "../../../snow-objects/terraform/modules/database"

  db_name    = "${upper(local.resource_prefix_with_env)}_DW_DB"
  db_comment = "Database to store the DW data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.required_snowflake_role, module.dbt_role.role.name]
    "USAGE"         = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE", "${upper(var.required_project_code)}_ANALYST_ROLE"]
  }

  schemas = ["DIM", "FACT", "UTIL"]

  schema_grant = {
    "DIM OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "DIM USAGE"        = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE", "${upper(var.required_project_code)}_ANALYST_ROLE"] },
    "DIM CREATE TABLE" = { "roles" = [module.dbt_role.role.name] },
    "DIM CREATE VIEW"  = { "roles" = [module.dbt_role.role.name] },

    "FACT OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "FACT USAGE"        = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE", "${upper(var.required_project_code)}_ANALYST_ROLE"] },
    "FACT CREATE TABLE" = { "roles" = [module.dbt_role.role.name] },
    "FACT CREATE VIEW"  = { "roles" = [module.dbt_role.role.name] }

    "UTIL OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "UTIL USAGE"        = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE", "${upper(var.required_project_code)}_ANALYST_ROLE"] },
    "UTIL CREATE TABLE" = { "roles" = [module.dbt_role.role.name] },
    "UTIL CREATE VIEW"  = { "roles" = [module.dbt_role.role.name] }

  }

  table_grant = {
    "DIM SELECT"  = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE", "${upper(var.required_project_code)}_ANALYST_ROLE"] },
    "FACT SELECT" = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE", "${upper(var.required_project_code)}_ANALYST_ROLE"] },
    "UTIL SELECT" = { "roles" = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DEVELOPER_ROLE", "${upper(var.required_project_code)}_ANALYST_ROLE"] }
  }

  depends_on = [module.dbt_role.role, module.developer_role.role]
}

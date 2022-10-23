//***************************************************************************//
// Create Snowflake warehouse using modules
//***************************************************************************//

module "entechlog_dbt_wh_xs" {
  source                 = "./warehouse"
  warehouse_name         = "${upper(var.env_code)}_ENTECHLOG_DBT_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30
  warehouse_grant_roles = {
    "OWNERSHIP" = ["SYSADMIN"]
    "MODIFY"    = [var.snowflake_role]
    "USAGE"     = (upper(var.env_code) == "DEV" ? [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] : [module.entechlog_dbt_role.role.name])
    "MONITOR"   = [module.entechlog_dbt_role.role.name]
  }

  depends_on = [module.entechlog_dbt_role.role, module.entechlog_developer_role.role]
}

module "entechlog_query_wh_xs" {
  source                 = "./warehouse"
  count                  = local.enable_in_dev_flag
  warehouse_name         = "ALL_ENTECHLOG_QUERY_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30
  warehouse_grant_roles = {
    "OWNERSHIP" = ["SYSADMIN"]
    "MODIFY"    = [var.snowflake_role]
    "USAGE"     = [module.entechlog_analyst_role[0].role.name, module.entechlog_developer_role[0].role.name]
    "MONITOR"   = [module.entechlog_dbt_role.role.name]
  }

  depends_on = [module.entechlog_analyst_role.role, module.entechlog_developer_role.role]
}

module "entechlog_demo_wh_xs" {
  source                 = "./warehouse"
  warehouse_name         = "${upper(var.env_code)}_ENTECHLOG_DEMO_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30
  warehouse_grant_roles = {
    "OWNERSHIP" = ["SYSADMIN"]
    "MODIFY"    = [var.snowflake_role]
    "USAGE"     = [module.entechlog_demo_role[0].role.name]
    "MONITOR"   = [module.entechlog_demo_role[0].role.name]
  }

  depends_on = [module.entechlog_demo_role.role]
}

//***************************************************************************//
// Create Snowflake database and schema using modules
//***************************************************************************//

// RAW Layer

module "entechlog_raw_db" {
  source = "./database"

  db_name    = "${upper(var.env_code)}_ENTECHLOG_RAW_DB"
  db_comment = "Database to store the ingested RAW data"

  db_grant_roles = {
    "OWNERSHIP"          = ["SYSADMIN"]
    "CREATE SCHEMA"      = [var.snowflake_role, module.entechlog_kafka_role.role.name]
    # "CREATE INTEGRATION" = [var.snowflake_role, module.entechlog_demo_role[0].role.name]
    "USAGE"              = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", module.entechlog_kafka_role.role.name]
  }

  schemas = ["DATAGEN"]

  /* https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html#schema-privileges */
  schema_grant = {
    "DATAGEN OWNERSHIP"       = { "roles" = ["SYSADMIN"] },
    "DATAGEN USAGE"           = { "roles" = [var.snowflake_role, module.entechlog_dbt_role.role.name, module.entechlog_atlan_role.role.name, module.entechlog_kafka_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
    "DATAGEN CREATE TABLE"    = { "roles" = [module.entechlog_kafka_role.role.name] },
    "DATAGEN CREATE VIEW"     = { "roles" = [module.entechlog_kafka_role.role.name] },
    "DATAGEN CREATE STAGE"    = { "roles" = [module.entechlog_kafka_role.role.name] },
    "DATAGEN CREATE PIPE"     = { "roles" = [module.entechlog_kafka_role.role.name] },
    "DATAGEN CREATE FUNCTION" = { "roles" = [var.snowflake_role, module.entechlog_demo_role[0].role.name] },
  }

  table_grant = {
    "DATAGEN SELECT" = { "roles" = [module.entechlog_atlan_role.role.name, module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] }
  }

  depends_on = [module.entechlog_dbt_role.role, module.entechlog_atlan_role.role, module.entechlog_kafka_role.role]
}

// Staging Layer, No user access other than dbt roles and developer role

module "entechlog_staging_db" {
  source = "./database"

  db_name    = "${upper(var.env_code)}_ENTECHLOG_STAGING_DB"
  db_comment = "Database to store the standardized data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.snowflake_role, module.entechlog_dbt_role.role.name]
    "USAGE"         = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"]
  }

  schemas = ["DIM", "FACT", "UTILS"]

  schema_grant = {
    "DIM OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "DIM USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
    "DIM CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
    "DIM CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] },

    "FACT OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "FACT USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
    "FACT CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
    "FACT CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }

    "UTILS OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "UTILS USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
    "UTILS CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
    "UTILS CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }
  }

  table_grant = {
    "DIM SELECT"   = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
    "FACT SELECT"  = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
    "UTILS SELECT" = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] }
  }

  depends_on = [module.entechlog_dbt_role.role, module.entechlog_developer_role.role]
}

// DW Layer, This is the only layer an end user should have access

module "entechlog_dw_db" {
  source = "./database"

  db_name    = "${upper(var.env_code)}_ENTECHLOG_DW_DB"
  db_comment = "Database to store the DW data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.snowflake_role, module.entechlog_dbt_role.role.name]
    "USAGE"         = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"]
  }

  schemas = ["DIM", "FACT", "UTILS", "COMPLIANCE"]

  schema_grant = {
    "DIM OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "DIM USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
    "DIM CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
    "DIM CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] },

    "FACT OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "FACT USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
    "FACT CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
    "FACT CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }

    "UTILS OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "UTILS USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
    "UTILS CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
    "UTILS CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }

    "COMPLIANCE OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
    "COMPLIANCE USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name] },
    "COMPLIANCE CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
    "COMPLIANCE CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }
  }

  table_grant = {
    "DIM SELECT"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
    "FACT SELECT"       = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
    "UTILS SELECT"      = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
    "COMPLIANCE SELECT" = { "roles" = [module.entechlog_dbt_role.role.name] }
  }

  depends_on = [module.entechlog_dbt_role.role, module.entechlog_developer_role.role]
}

// Output block starts here

output "entechlog_raw_db" {
  value = module.entechlog_raw_db
}

output "entechlog_staging_db" {
  value = module.entechlog_staging_db
}

output "entechlog_dw_db" {
  value = module.entechlog_dw_db
}

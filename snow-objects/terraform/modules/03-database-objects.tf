//***************************************************************************//
// Create Snowflake warehouse using modules
//***************************************************************************//

module "entechlog_dbt_wh_xs" {
  source                 = "./warehouse"
  warehouse_name         = "${upper(var.env_code)}_ENTECHLOG_DBT_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30

  warehouse_grant = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "snowflake_role" = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["MODIFY"] },
    "dbt_role"       = { "role_name" = "${module.entechlog_dbt_role.role.name}", "privileges" = ["USAGE", "MONITOR"] },
  }

  depends_on = [module.entechlog_dbt_role.role, module.entechlog_developer_role.role]
}

module "entechlog_query_wh_xs" {
  source                 = "./warehouse"
  count                  = local.enable_in_dev_flag
  warehouse_name         = "ALL_ENTECHLOG_QUERY_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30

  warehouse_grant = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "snowflake_role" = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["MODIFY"] },
    "dbt_role"       = { "role_name" = "${module.entechlog_dbt_role.role.name}", "privileges" = ["USAGE", "MONITOR"] },
    "analyst_role"   = { "role_name" = "${module.entechlog_analyst_role[0].role.name}", "privileges" = ["USAGE"] },
  }

  depends_on = [module.entechlog_analyst_role.role, module.entechlog_developer_role.role]
}

module "entechlog_demo_wh_xs" {
  source                 = "./warehouse"
  warehouse_name         = "${upper(var.env_code)}_ENTECHLOG_DEMO_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30

  warehouse_grant = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "snowflake_role" = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["MODIFY"] },
    "demo_role"      = { "role_name" = "${module.entechlog_demo_role[0].role.name}", "privileges" = ["USAGE", "MONITOR"] },
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
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.snowflake_role, module.entechlog_kafka_role.role.name]
    # "CREATE INTEGRATION" = [var.snowflake_role, module.entechlog_demo_role[0].role.name]
    "USAGE" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", module.entechlog_kafka_role.role.name]
  }

  schemas = ["DATAGEN", "SEED", "YELLOW_TAXI"]

  /* https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html#schema-privileges */
  schema_grant = {
    "SEED sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "SEED snowflake_role" = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "SEED dbt_role"       = { "role_name" = "${module.entechlog_dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "SEED atlan_role"     = { "role_name" = "${module.entechlog_atlan_role.role.name}", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "SEED kafka_role"     = { "role_name" = "${module.entechlog_kafka_role.role.name}", "privileges" = ["USAGE"] },
    "SEED developer_role" = { "role_name" = "ENTECHLOG_DEVELOPER_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },

    "DATAGEN sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DATAGEN snowflake_role" = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "DATAGEN dbt_role"       = { "role_name" = "${module.entechlog_dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "DATAGEN atlan_role"     = { "role_name" = "${module.entechlog_atlan_role.role.name}", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "DATAGEN kafka_role"     = { "role_name" = "${module.entechlog_kafka_role.role.name}", "privileges" = ["USAGE"] },
    "DATAGEN developer_role" = { "role_name" = "ENTECHLOG_DEVELOPER_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },

    "YELLOW_TAXI sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "YELLOW_TAXI snowflake_role" = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "YELLOW_TAXI dbt_role"       = { "role_name" = "${module.entechlog_dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
  }

  table_grant = {
    "SEED dbt_role"       = { "role_name" = "${module.entechlog_dbt_role.role.name}", "privileges" = ["SELECT"] },
    "SEED developer_role" = { "role_name" = "ENTECHLOG_DEVELOPER_ROLE", "privileges" = ["SELECT"] },

    "DATAGEN dbt_role"       = { "role_name" = "${module.entechlog_dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DATAGEN developer_role" = { "role_name" = "ENTECHLOG_DEVELOPER_ROLE", "privileges" = ["SELECT"] },

    "YELLOW_TAXI dbt_role"       = { "role_name" = "${module.entechlog_dbt_role.role.name}", "privileges" = ["SELECT"] },
    "YELLOW_TAXI developer_role" = { "role_name" = "ENTECHLOG_DEVELOPER_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.entechlog_dbt_role.role, module.entechlog_atlan_role.role, module.entechlog_kafka_role.role]
}

// Staging Layer, No user access other than dbt roles and developer role

# module "entechlog_staging_db" {
#   source = "./database"

#   db_name    = "${upper(var.env_code)}_ENTECHLOG_STAGING_DB"
#   db_comment = "Database to store the standardized data"

#   db_grant_roles = {
#     "OWNERSHIP"     = ["SYSADMIN"]
#     "CREATE SCHEMA" = [var.snowflake_role, module.entechlog_dbt_role.role.name]
#     "USAGE"         = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"]
#   }

#   schemas = ["DIM", "FACT", "UTIL"]

#   schema_grant = {
#     "DIM OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
#     "DIM USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
#     "DIM CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
#     "DIM CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] },

#     "FACT OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
#     "FACT USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
#     "FACT CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
#     "FACT CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }

#     "UTIL OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
#     "UTIL USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
#     "UTIL CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
#     "UTIL CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }
#   }

#   table_grant = {
#     "DIM SELECT"  = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
#     "FACT SELECT" = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] },
#     "UTIL SELECT" = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE"] }
#   }

#   depends_on = [module.entechlog_dbt_role.role, module.entechlog_developer_role.role]
# }

# // DW Layer, This is the only layer an end user should have access

# module "entechlog_dw_db" {
#   source = "./database"

#   db_name    = "${upper(var.env_code)}_ENTECHLOG_DW_DB"
#   db_comment = "Database to store the DW data"

#   db_grant_roles = {
#     "OWNERSHIP"     = ["SYSADMIN"]
#     "CREATE SCHEMA" = [var.snowflake_role, module.entechlog_dbt_role.role.name]
#     "USAGE"         = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"]
#   }

#   schemas = ["DIM", "FACT", "UTIL", "COMPLIANCE"]

#   schema_grant = {
#     "DIM OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
#     "DIM USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
#     "DIM CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
#     "DIM CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] },

#     "FACT OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
#     "FACT USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
#     "FACT CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
#     "FACT CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }

#     "UTIL OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
#     "UTIL USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
#     "UTIL CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
#     "UTIL CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }

#     "COMPLIANCE OWNERSHIP"    = { "roles" = ["SYSADMIN"] },
#     "COMPLIANCE USAGE"        = { "roles" = [module.entechlog_dbt_role.role.name] },
#     "COMPLIANCE CREATE TABLE" = { "roles" = [module.entechlog_dbt_role.role.name] },
#     "COMPLIANCE CREATE VIEW"  = { "roles" = [module.entechlog_dbt_role.role.name] }
#   }

#   table_grant = {
#     "DIM SELECT"        = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
#     "FACT SELECT"       = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
#     "UTIL SELECT"       = { "roles" = [module.entechlog_dbt_role.role.name, "ENTECHLOG_DEVELOPER_ROLE", "ENTECHLOG_ANALYST_ROLE"] },
#     "COMPLIANCE SELECT" = { "roles" = [module.entechlog_dbt_role.role.name] }
#   }

#   depends_on = [module.entechlog_dbt_role.role, module.entechlog_developer_role.role]
# }

# // Output block starts here

# output "entechlog_raw_db" {
#   value = module.entechlog_raw_db
# }

# output "entechlog_staging_db" {
#   value = module.entechlog_staging_db
# }

# output "entechlog_dw_db" {
#   value = module.entechlog_dw_db
# }

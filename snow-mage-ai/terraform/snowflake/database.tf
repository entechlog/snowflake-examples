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
    "CREATE SCHEMA" = [var.snowflake_role]
    "USAGE"         = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DE_ROLE"]
  }

  schemas = ["SEED", "CRICSHEET", "CRICINFO"]

  /* https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html#schema-privileges */
  schema_grant = {
    "SEED sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "SEED snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "SEED dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "SEED data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "SEED data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["USAGE"] },

    "CRICSHEET sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "CRICSHEET snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "CRICSHEET dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "CRICSHEET data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "CRICSHEET data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["USAGE"] },

    "CRICINFO sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "CRICINFO snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "CRICINFO dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "CRICINFO data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "CRICINFO data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["USAGE"] },
  }

  table_grant = {
    "SEED dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "SEED data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },
    "SEED data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["SELECT"] },

    "CRICSHEET dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "CRICSHEET data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },
    "CRICSHEET data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["SELECT"] },

    "CRICINFO dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "CRICINFO data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },
    "CRICINFO data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.dbt_role.role, module.da_role.role, module.de_role.role]
}

// Staging Layer, No user access other than dbt roles and developer role

module "prep_db" {
  source = "../../../snow-objects/terraform/modules/database"

  db_name    = "${upper(local.resource_prefix_with_env)}_PREP_DB"
  db_comment = "Database to store the standardized data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.snowflake_role, module.dbt_role.role.name]
    "USAGE"         = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DE_ROLE"]
  }

  schemas = ["DIM", "FACT", "UTIL"]

  schema_grant = {
    "DIM sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DIM snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "DIM dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "DIM data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },

    "FACT sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "FACT snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "FACT dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "FACT data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },

    "UTIL sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "UTIL snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "UTIL dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "UTIL data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
  }

  table_grant = {
    "DIM dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DIM data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },

    "FACT dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "FACT data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },

    "UTIL dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "UTIL data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.dbt_role.role, module.de_role.role]
}

// DW Layer, This is the only layer an end user should have access

module "dw_db" {
  source = "../../../snow-objects/terraform/modules/database"

  db_name    = "${upper(local.resource_prefix_with_env)}_DW_DB"
  db_comment = "Database to store the DW data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.snowflake_role, module.dbt_role.role.name]
    "USAGE"         = [module.dbt_role.role.name, "${upper(local.resource_prefix_without_env)}_DE_ROLE", "${upper(var.project_code)}_DA_ROLE"]
  }

  schemas = ["DIM", "FACT", "UTIL", "ANALYTICS"]

  schema_grant = {
    "DIM sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DIM snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "DIM dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "DIM data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "DIM data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["USAGE"] },

    "FACT sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "FACT snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "FACT dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "FACT data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "FACT data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["USAGE"] },

    "UTIL sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "UTIL snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "UTIL dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "UTIL data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "UTIL data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["USAGE"] },

    "ANALYTICS sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "ANALYTICS snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["USAGE"] },
    "ANALYTICS dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "ANALYTICS data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "ANALYTICS data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["USAGE"] },
  }

  table_grant = {
    "DIM dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DIM data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },
    "DIM data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["SELECT"] },

    "FACT dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "FACT data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },
    "FACT data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["SELECT"] },

    "UTIL dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "UTIL data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },
    "UTIL data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["SELECT"] },

    "ANALYTICS dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "ANALYTICS data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DE_ROLE", "privileges" = ["SELECT"] },
    "ANALYTICS data_analyst_role"  = { "role_name" = "${upper(local.resource_prefix_without_env)}_DA_ROLE", "privileges" = ["SELECT"] },
  }


  depends_on = [module.dbt_role.role, module.da_role.role, module.de_role.role]
}

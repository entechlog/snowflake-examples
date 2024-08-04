//***************************************************************************//
// Create Snowflake database and schema using modules
//***************************************************************************//

// DW Layer, This is the only layer an end user should have access

module "dw_db" {
  source = "./modules/database"

  db_name    = "${upper(local.resource_name_prefix)}_DW_DB"
  db_comment = "Database to store the DW data"

  db_grants = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["CREATE SCHEMA"] },
    "dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE SCHEMA"] },
    "de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["USAGE"] },
    "da_role"        = { "role_name" = "${upper(var.project_code)}_DA_ROLE", "privileges" = ["USAGE"] },
  }

  schemas = ["DIM", "FACT", "UTIL", "COMPLIANCE"]

  schema_grant = {
    "DIM sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DIM terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "DIM dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "DIM de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },
    "DIM da_role"        = { "role_name" = "${upper(var.project_code)}_DA_ROLE", "privileges" = ["USAGE"] },

    "FACT sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "FACT terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "FACT dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "FACT de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },
    "FACT da_role"        = { "role_name" = "${upper(var.project_code)}_DA_ROLE", "privileges" = ["USAGE"] },

    "UTIL sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "UTIL terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "UTIL dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "UTIL de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },
    "UTIL da_role"        = { "role_name" = "${upper(var.project_code)}_DA_ROLE", "privileges" = ["USAGE"] },

    "COMPLIANCE sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "COMPLIANCE terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "COMPLIANCE dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "COMPLIANCE de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },
    "COMPLIANCE da_role"        = { "role_name" = "${upper(var.project_code)}_DA_ROLE", "privileges" = ["USAGE"] },
  }

  table_grant = {
    "DIM dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DIM de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },
    "DIM da_role"  = { "role_name" = "${upper(var.project_code)}_DA_ROLE", "privileges" = ["SELECT"] },

    "FACT dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "FACT de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },
    "FACT da_role"  = { "role_name" = "${upper(var.project_code)}_DA_ROLE", "privileges" = ["SELECT"] },

    "UTIL dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "UTIL de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },
    "UTIL da_role"  = { "role_name" = "${upper(var.project_code)}_DA_ROLE", "privileges" = ["SELECT"] },

    "COMPLIANCE dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "COMPLIANCE de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },
    "COMPLIANCE da_role"  = { "role_name" = "${upper(var.project_code)}_DA_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.dbt_role.role, module.de_role.role, module.da_role.role]
}


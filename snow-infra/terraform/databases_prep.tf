//***************************************************************************//
// Create Snowflake database and schema using modules
//***************************************************************************//

// Staging Layer, No user access other than dbt roles and developer role

module "prep_db" {
  source = "./modules/database"

  db_name    = "${upper(local.resource_name_prefix)}_PREP_DB"
  db_comment = "Database to store the standardized data"

  db_grants = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["CREATE SCHEMA"] },
    "dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE SCHEMA"] },
    "de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["USAGE"] },
  }

  schemas = ["DIM", "FACT", "UTIL"]

  schema_grant = {
    "DIM sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DIM terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "DIM dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "DIM de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },

    "FACT sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "FACT terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "FACT dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "FACT de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },

    "UTIL sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "UTIL terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "UTIL dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "UTIL de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },

  }

  table_grant = {
    "DIM dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DIM de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },

    "FACT dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "FACT de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },

    "UTIL dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "UTIL de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.dbt_role.role, module.de_role.role]
}
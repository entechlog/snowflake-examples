//***************************************************************************//
// Create Snowflake database and schema using modules
//***************************************************************************//

// RAW Layer

module "raw_db" {
  source = "./modules/database"

  db_name    = "${upper(var.env_code)}_ENTECHLOG_RAW_DB"
  db_comment = "Database to store the ingested RAW data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.terraform_role, module.kafka_role.role.name]
    # "CREATE INTEGRATION" = [var.terraform_role, module.entechlog_demo_role[0].role.name]
    "USAGE" = [module.dbt_role.role.name, "ENTECHLOG_DE_ROLE", module.kafka_role.role.name]
  }

  schemas = ["DATAGEN", "SEED", "YELLOW_TAXI"]

  /* https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html#schema-privileges */
  schema_grant = {
    "SEED sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "SEED terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "SEED dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "SEED atlan_role"     = { "role_name" = "${module.atlan_role.role.name}", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "SEED kafka_role"     = { "role_name" = "${module.kafka_role.role.name}", "privileges" = ["USAGE"] },
    "SEED de_role"        = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },

    "DATAGEN sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DATAGEN terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "DATAGEN dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "DATAGEN atlan_role"     = { "role_name" = "${module.atlan_role.role.name}", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "DATAGEN kafka_role"     = { "role_name" = "${module.kafka_role.role.name}", "privileges" = ["USAGE"] },
    "DATAGEN de_role"        = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },

    "YELLOW_TAXI sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "YELLOW_TAXI terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "YELLOW_TAXI dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
  }

  table_grant = {
    "SEED dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "SEED de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },

    "DATAGEN dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DATAGEN de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },

    "YELLOW_TAXI dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "YELLOW_TAXI de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.dbt_role.role, module.atlan_role.role, module.kafka_role.role]
}

// Staging Layer, No user access other than dbt roles and developer role

module "prep_db" {
  source = "./modules/database"

  db_name    = "${upper(var.env_code)}_ENTECHLOG_PREP_DB"
  db_comment = "Database to store the standardized data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.terraform_role, module.dbt_role.role.name]
    "USAGE"         = [module.dbt_role.role.name, "ENTECHLOG_DE_ROLE"]
  }

  schemas = ["DIM", "FACT", "UTIL"]

  schema_grant = {
    "DIM sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DIM terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "DIM dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "DIM de_role"        = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },

    "FACT sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "FACT terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "FACT dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "FACT de_role"        = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },

    "UTIL sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "UTIL terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "UTIL dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "UTIL de_role"        = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },

  }

  table_grant = {
    "DIM dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DIM de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },

    "FACT dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "FACT de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },

    "UTIL dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "UTIL de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.dbt_role.role, module.de_role.role]
}

// DW Layer, This is the only layer an end user should have access

module "dw_db" {
  source = "./modules/database"

  db_name    = "${upper(var.env_code)}_ENTECHLOG_DW_DB"
  db_comment = "Database to store the DW data"

  db_grant_roles = {
    "OWNERSHIP"     = ["SYSADMIN"]
    "CREATE SCHEMA" = [var.terraform_role, module.dbt_role.role.name]
    "USAGE"         = [module.dbt_role.role.name, "ENTECHLOG_DE_ROLE", "ENTECHLOG_DA_ROLE"]
  }

  schemas = ["DIM", "FACT", "UTIL", "COMPLIANCE"]

  schema_grant = {
    "DIM sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DIM terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "DIM dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "DIM de_role"        = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },
    "DIM da_role"        = { "role_name" = "ENTECHLOG_DA_ROLE", "privileges" = ["USAGE"] },

    "FACT sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "FACT terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "FACT dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "FACT de_role"        = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },
    "FACT da_role"        = { "role_name" = "ENTECHLOG_DA_ROLE", "privileges" = ["USAGE"] },

    "UTIL sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "UTIL terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "UTIL dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "UTIL de_role"        = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },
    "UTIL da_role"        = { "role_name" = "ENTECHLOG_DA_ROLE", "privileges" = ["USAGE"] },

    "COMPLIANCE sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "COMPLIANCE terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "COMPLIANCE dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },
    "COMPLIANCE de_role"        = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW"] : ["USAGE"]) },
    "COMPLIANCE da_role"        = { "role_name" = "ENTECHLOG_DA_ROLE", "privileges" = ["USAGE"] },
  }

  table_grant = {
    "DIM dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DIM de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },
    "DIM da_role"  = { "role_name" = "ENTECHLOG_DA_ROLE", "privileges" = ["SELECT"] },

    "FACT dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "FACT de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },
    "FACT da_role"  = { "role_name" = "ENTECHLOG_DA_ROLE", "privileges" = ["SELECT"] },

    "UTIL dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "UTIL de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },
    "UTIL da_role"  = { "role_name" = "ENTECHLOG_DA_ROLE", "privileges" = ["SELECT"] },

    "COMPLIANCE dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "COMPLIANCE de_role"  = { "role_name" = "ENTECHLOG_DE_ROLE", "privileges" = ["SELECT"] },
    "COMPLIANCE da_role"  = { "role_name" = "ENTECHLOG_DA_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.dbt_role.role, module.de_role.role]
}


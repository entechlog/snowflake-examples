//***************************************************************************//
// Create Snowflake database and schema using modules
//***************************************************************************//

// RAW Layer

module "raw_db" {
  source = "./modules/database"

  db_name    = "${upper(local.resource_name_prefix)}_RAW_DB"
  db_comment = "Database to store the ingested RAW data"

  db_grants = {
    "sysadmin_role"   = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "terraform_role"  = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE", "CREATE SCHEMA"] },
    "kafka_role"      = { "role_name" = "${module.kafka_role.role.name}", "privileges" = ["USAGE", "CREATE SCHEMA"] },
    "dbt_role"        = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE"] },
    "de_role"         = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["USAGE"] },
    "pipe_admin_role" = { "role_name" = "${upper(var.project_code)}_PIPE_ADMIN_ROLE", "privileges" = ["USAGE"] },
  }

  schemas = ["DATAGEN", "SEED", "YELLOW_TAXI", "UTIL", "FAKER"]

  /* https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html#schema-privileges */
  schema_grant = {
    "SEED sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "SEED terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "SEED dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "SEED de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },

    "DATAGEN sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DATAGEN terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE", "CREATE FILE FORMAT", "CREATE STAGE", "CREATE ICEBERG TABLE"] },
    "DATAGEN dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "DATAGEN de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "DATAGEN kafka_role"     = { "role_name" = "${module.kafka_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW"] },

    "YELLOW_TAXI sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "YELLOW_TAXI terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "YELLOW_TAXI dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },

    "FAKER sysadmin_role"   = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "FAKER terraform_role"  = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE", "CREATE FILE FORMAT", "CREATE STAGE", "CREATE ICEBERG TABLE"] },
    "FAKER dbt_role"        = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "FAKER pipe_admin_role" = { "role_name" = "${upper(var.project_code)}_PIPE_ADMIN_ROLE", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },

    "UTIL sysadmin_role"   = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "UTIL terraform_role"  = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE", "CREATE FILE FORMAT", "CREATE STAGE"] },
    "UTIL dbt_role"        = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "UTIL pipe_admin_role" = { "role_name" = "${upper(var.project_code)}_PIPE_ADMIN_ROLE", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
  }

  table_grant = {
    "SEED dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "SEED de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },

    "DATAGEN dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DATAGEN de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },

    "YELLOW_TAXI dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "YELLOW_TAXI de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },

    "FAKER dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "FAKER de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },

    "UTIL dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "UTIL de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.dbt_role.role]
}
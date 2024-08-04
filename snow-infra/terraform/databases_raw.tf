//***************************************************************************//
// Create Snowflake database and schema using modules
//***************************************************************************//

// RAW Layer

module "raw_db" {
  source = "./modules/database"

  db_name    = "${upper(local.resource_name_prefix)}_RAW_DB"
  db_comment = "Database to store the ingested RAW data"

  db_grants = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["CREATE SCHEMA"] },
    "kafka_role"     = { "role_name" = "${module.kafka_role.role.name}", "privileges" = ["USAGE", "CREATE SCHEMA"] },
    "dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE"] },
    "de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["USAGE"] },
  }

  schemas = ["DATAGEN", "SEED", "YELLOW_TAXI"]

  /* https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html#schema-privileges */
  schema_grant = {
    "SEED sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "SEED terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "SEED dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "SEED atlan_role"     = { "role_name" = "${module.atlan_role.role.name}", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "SEED kafka_role"     = { "role_name" = "${module.kafka_role.role.name}", "privileges" = ["USAGE"] },
    "SEED de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },

    "DATAGEN sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "DATAGEN terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "DATAGEN dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
    "DATAGEN atlan_role"     = { "role_name" = "${module.atlan_role.role.name}", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },
    "DATAGEN kafka_role"     = { "role_name" = "${module.kafka_role.role.name}", "privileges" = ["USAGE"] },
    "DATAGEN de_role"        = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = (upper(var.env_code) == "DEV" ? ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE PIPE"] : ["USAGE"]) },

    "YELLOW_TAXI sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "YELLOW_TAXI terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["USAGE"] },
    "YELLOW_TAXI dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "CREATE TABLE", "CREATE VIEW", "CREATE STAGE", "CREATE PIPE"] },
  }

  table_grant = {
    "SEED dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "SEED de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },

    "DATAGEN dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "DATAGEN de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },

    "YELLOW_TAXI dbt_role" = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["SELECT"] },
    "YELLOW_TAXI de_role"  = { "role_name" = "${upper(var.project_code)}_DE_ROLE", "privileges" = ["SELECT"] },
  }

  depends_on = [module.dbt_role.role, module.atlan_role.role, module.kafka_role.role]
}
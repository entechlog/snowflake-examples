resource "snowflake_stage" "this" {
  name                = "${upper(local.resource_prefix_with_env)}_CRICSHEET_S3_STG"
  storage_integration = module.str_s3_intg.storage_integration.id
  url                 = "${var.snowflake_storage_integration__storage_allowed_locations[0]}/"
  database            = module.raw_db.database.name
  schema              = "CRICSHEET"
}

resource "snowflake_stage_grant" "this" {
  database_name = module.raw_db.database.name
  schema_name   = "CRICSHEET"
  roles         = ["${module.dbt_role.role.name}"]
  privilege     = "OWNERSHIP"
  stage_name    = snowflake_stage.this.name
}
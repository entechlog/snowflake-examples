//***************************************************************************//
// Create storage integration using modules
//***************************************************************************//

module "str_s3_intg" {
  source                    = "../../../snow-objects/terraform/modules/storage-integration"
  name                      = "${upper(local.resource_prefix_with_env)}_STR_S3_INTG"
  comment                   = ""
  storage_provider          = "S3"
  enabled                   = true
  storage_allowed_locations = var.snowflake_storage_integration__storage_allowed_locations
  storage_blocked_locations = var.snowflake_storage_integration__storage_blocked_locations
  storage_aws_role_arn      = var.snowflake__aws_role_arn
  roles                     = [module.dbt_role.role.name]
}

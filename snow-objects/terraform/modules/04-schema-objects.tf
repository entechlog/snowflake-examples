//***************************************************************************//
// Create masking policy using modules
//***************************************************************************//

# module "mp_encrypt_email" {
#   source                   = "./masking-policy"
#   count                    = local.enable_in_prod_flag
#   masking_policy_name      = "MP_ENCRYPT_EMAIL"
#   masking_policy_database  = module.entechlog_dw_db.database.name
#   masking_policy_schema    = module.entechlog_dw_db.schema["COMPLIANCE"].name
#   masking_value_data_type  = "VARCHAR"
#   masking_expression       = "CASE WHEN CURRENT_ROLE() IN ('SYSADMIN') THEN val ELSE '**********' END"
#   masking_return_data_type = "VARCHAR(16777216)"

#   masking_grants = {
#     "OWNERSHIP" = ["SYSADMIN"]
#     "APPLY"     = [module.entechlog_dbt_role.role.name]
#   }

# }

//***************************************************************************//
// Create storage integration using modules
//***************************************************************************//

module "entechlog_str_s3_intg" {
  source                    = "./storage-integration"
  count                     = local.enable_in_prod_flag
  name                      = "ENTECHLOG_STR_S3_INTG"
  comment                   = ""
  storage_provider          = "S3"
  enabled                   = true
  storage_allowed_locations = ["s3://entechlog-demo/kafka-snowpipe-demo/"]
  storage_blocked_locations = ["s3://entechlog-demo/secure/"]
  storage_aws_role_arn      = "arn:aws:iam::001234567890:role/myrole"
  roles                     = [module.entechlog_dbt_role.role.name]
}

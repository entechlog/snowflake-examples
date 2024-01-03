output "service_account_login_names" {
  value = module.all_service_accounts.snowflake_user__login_names
}

output "user_accounts_login_names" {
  value = module.all_user_accounts[0].snowflake_user__login_names
}

output "dbt_role_name" {
  value = module.dbt_role.role.name
}

output "analyst_role_name" {
  value = module.da_role[0].role.name
}

output "developer_role_name" {
  value = module.de_role[0].role.name
}

output "dbt_wh_xs_name" {
  value = module.dbt_wh_xs.warehouse.name
}

output "query_wh_xs_name" {
  value = join(", ", [for obj in module.query_wh_xs : obj.warehouse.name])
}

output "raw_db_name" {
  value = module.raw_db.database.name
}

output "raw_db_schemas" {
  value = join(", ", [for schema in values(module.raw_db.schema) : schema.name])
}

output "prep_db_name" {
  value = module.prep_db.database.name
}

output "prep_db_schemas" {
  value = join(", ", [for schema in values(module.prep_db.schema) : schema.name])
}

output "dw_db_name" {
  value = module.dw_db.database.name
}

output "dw_db_schemas" {
  value = join(", ", [for schema in values(module.dw_db.schema) : schema.name])
}

output "storage_integration_name" {
  value = module.str_s3_intg.storage_integration.name
}

output "storage_integration_aws_external_id" {
  value = module.str_s3_intg.storage_integration.storage_aws_external_id
}

output "storage_integration_aws_iam_user_arn" {
  value = module.str_s3_intg.storage_integration.storage_aws_iam_user_arn
}
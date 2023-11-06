//***************************************************************************//
// Create Snowflake warehouse using modules
//***************************************************************************//

module "dbt_wh_xs" {
  source                 = "../../../snow-objects/terraform/modules/warehouse"
  warehouse_name         = "${upper(local.resource_prefix_with_env)}_DBT_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30
  warehouse_grant = {
    "sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["MODIFY"] },
    "dbt_role"           = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "MONITOR"] },
    "data_engineer_role" = { "role_name" = "${upper(local.resource_prefix_without_env)}_DATA_ENGINEER_ROLE", "privileges" = ["USAGE"] },
  }

  depends_on = [module.dbt_role.role, module.de_role.role]
}

module "query_wh_xs" {
  source                 = "../../../snow-objects/terraform/modules/warehouse"
  count                  = local.enable_in_dev_flag
  warehouse_name         = "ALL_${upper(local.resource_prefix_without_env)}_QUERY_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30

  warehouse_grant = {
    "sysadmin_role"      = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "snowflake_role"     = { "role_name" = "${upper(var.snowflake_role)}", "privileges" = ["MODIFY"] },
    "data_analyst_role"  = { "role_name" = "${module.da_role[0].role.name}", "privileges" = ["USAGE"] },
    "data_engineer_role" = { "role_name" = "${module.de_role[0].role.name}", "privileges" = ["USAGE"] },
  }

  depends_on = [module.da_role.role, module.de_role.role]
}
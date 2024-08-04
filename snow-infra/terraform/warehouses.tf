//***************************************************************************//
// Create Snowflake warehouse using modules
//***************************************************************************//

module "dbt_wh_xs" {
  source                 = "./modules/warehouse"
  warehouse_name         = "${upper(local.resource_name_prefix)}_DBT_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30

  warehouse_grant = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["MODIFY"] },
    "dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "MONITOR"] },
  }

  depends_on = [module.dbt_role.role]
}

module "query_wh_xs" {
  source                 = "./modules/warehouse"
  count                  = local.enable_in_dev_flag
  warehouse_name         = "ALL_ENTECHLOG_QUERY_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30

  warehouse_grant = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["MODIFY"] },
    "dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "MONITOR"] },
    "da_role"        = { "role_name" = "${module.da_role[0].role.name}", "privileges" = ["USAGE"] },
    "de_role"        = { "role_name" = "${module.de_role[0].role.name}", "privileges" = ["USAGE"] },
  }

  depends_on = [module.dbt_role.role, module.da_role.role, module.de_role.role]
}

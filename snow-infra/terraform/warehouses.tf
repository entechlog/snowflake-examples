//***************************************************************************//
// Create Snowflake warehouse using modules
//***************************************************************************//

module "entechlog_dbt_wh_xs" {
  source                 = "./modules/warehouse"
  warehouse_name         = "${upper(var.env_code)}_ENTECHLOG_DBT_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30

  warehouse_grant = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["MODIFY"] },
    "dbt_role"       = { "role_name" = "${module.dbt_role.role.name}", "privileges" = ["USAGE", "MONITOR"] },
  }

  depends_on = [module.dbt_role.role, module.de_role.role]
}

module "entechlog_query_wh_xs" {
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
  }

  depends_on = [module.da_role.role, module.de_role.role]
}

module "entechlog_demo_wh_xs" {
  source                 = "./modules/warehouse"
  warehouse_name         = "${upper(var.env_code)}_ENTECHLOG_DEMO_WH_XS"
  warehouse_size         = "XSMALL"
  warehouse_auto_suspend = 30

  warehouse_grant = {
    "sysadmin_role"  = { "role_name" = "SYSADMIN", "privileges" = ["OWNERSHIP"] },
    "terraform_role" = { "role_name" = "${upper(var.terraform_role)}", "privileges" = ["MODIFY"] },
    "demo_role"      = { "role_name" = "${module.entechlog_demo_role.role.name}", "privileges" = ["USAGE", "MONITOR"] },
  }

  depends_on = [module.entechlog_demo_role.role]
}

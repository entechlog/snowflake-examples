resource "snowflake_grant_account_role" "sysadmin" {

  count     = local.enable_in_dev_flag
  role_name = "SYSADMIN"
  user_name = "admin@entechlog.com"
}
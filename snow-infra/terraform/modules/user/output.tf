output "snowflake_user__login_names" {
  value = join(", ", [for v in snowflake_user.user : v.login_name])
}

output "user" {
  value = snowflake_user.user
}
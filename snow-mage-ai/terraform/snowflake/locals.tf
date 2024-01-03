locals {
  resource_prefix_with_env = "${lower(var.env_code)}_${lower(var.project_code)}"

  resource_prefix_without_env = lower(var.project_code)

  tmp = "${lower(var.env_code)}_${lower(var.project_code)}_${lower(var.app_code)}"
}
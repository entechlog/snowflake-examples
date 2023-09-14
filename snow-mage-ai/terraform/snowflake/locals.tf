locals {
  resource_prefix_with_env = "${lower(var.required_env_code)}_${lower(var.required_project_code)}"

  resource_prefix_without_env = lower(var.required_project_code)

  tmp = "${lower(var.required_env_code)}_${lower(var.required_project_code)}_${lower(var.required_app_code)}"
}
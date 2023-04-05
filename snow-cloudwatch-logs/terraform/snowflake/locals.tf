locals {
  resource_name_prefix = var.use_env_code == true ? "${lower(var.env_code)}_${lower(var.project_code)}" : "${lower(var.project_code)}"
}

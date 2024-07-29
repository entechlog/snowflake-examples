# -------------------------------------------------------------------------
# Local Variables
# -------------------------------------------------------------------------
locals {
  # Determines the resource name prefix based on the use_env_code variable
  resource_name_prefix = var.use_env_code == true ? "${lower(var.env_code)}_${lower(var.project_code)}" : "${lower(var.project_code)}"
}

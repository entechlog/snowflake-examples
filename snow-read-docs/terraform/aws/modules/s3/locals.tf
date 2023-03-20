locals {
  account_id           = data.aws_caller_identity.current.account_id
  timestamp            = timestamp()
  date                 = formatdate("YYYY-MM-DD", local.timestamp)
  resource_name_prefix = var.use_env_code == true ? "${lower(var.env_code)}-${lower(var.project_code)}" : "${lower(var.project_code)}"

  tags = { Author = "Terraform" }
}
# Overview
This repo contains Terraform modules to create some common database objects in Snowflake.

# Instructions

```bash
# install custom modules
terraform init

# format code
terraform fmt -recursive

# plan to review the summary of changes
terraform plan

# apply the changes to target environment
terraform apply

# delete all resources from target, DO NOT do this in any environment unless its really needed 🔥
terraform destroy
```

# Reference 
- https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa
- https://www.udemy.com/course/terraform-snowflake-from-scratch
  
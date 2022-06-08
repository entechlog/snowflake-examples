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
terraform apply --auto-approve

# delete all resources from target, DO NOT do this in any environment unless its really needed 🔥
terraform destroy
terraform destroy --auto-approve

# Generate token by running
terraform login

# Migrate local state to backend
terraform init

# Remove local state after copying to backend
rm terraform.tfstate

# To upgrade provider version
terraform init -upgrade

# List Terrafrom state
terraform state list

# Remove all states, DO NOT do this in any environment unless its really needed 🔥
for i in $(terraform state list); do terraform state rm $i; done
```

# Reference 
- https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa
- https://www.udemy.com/course/terraform-snowflake-from-scratch
- https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html
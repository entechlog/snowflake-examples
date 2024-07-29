# Overview
This repo contains Terraform modules to create some common database objects in Snowflake.

# Instructions

```bash

# login
terraform login

# create workspace
terraform workspace new snowflake-dev

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

# Design

- Objects are named based on [Snowflake object naming conventions](https://www.entechlog.com/blog/data/snowflake-object-naming-conventions/)
- Idea is to have 3 workspaces in terraform, say snowflake-dev, snowflake-stg and snowflake-prd
- Development and Stage deployments happen when code is merged to develop branch
- Production deployments happen only when code is merged to main branch
- Common resources like user, role requires a production merge for deployment

# Reference 
- https://blog.gruntwork.io/how-to-manage-terraform-state-28f5697e68fa
- https://www.udemy.com/course/terraform-snowflake-from-scratch
- https://docs.snowflake.com/en/user-guide/security-access-control-privileges.html
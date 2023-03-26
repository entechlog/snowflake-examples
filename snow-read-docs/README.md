- [Overview](#overview)
- [Architecture](#architecture)
- [Instructions](#instructions)
  - [AWS](#aws)
  - [Blog](#blog)
  - [Terraform commands](#terraform-commands)
- [Reference](#reference)
- [Validate results](#validate-results)
- [Future Enhancements](#future-enhancements)
  
# Overview
This repo contains code to create resources required to parse document in AWS s3 using textract to and read them in AWS using Terraform.

# Architecture
See below diagram for high level architecture

<p align="center">
  <img src="./assets/overview.jpeg" alt="Overview" width="738">
</p>

# Instructions

## AWS

- cd into `terraform\aws`
- Create a copy of `terraform.tfvars.template` as `terraform.tfvar` and update the same with values for all required parameters. It's okay to not set `snowflake_api_aws_iam_user_arn` and `snowflake_api_aws_external_id` in the first run. This will be obtained from snowflake integration terraform output
- Create the resource by running following commands
  ```bash
  terraform init
  terraform plan
  terraform apply
  ```
- cd into `terraform\snowflake`
- Create a copy of `terraform.tfvars.template` as `terraform.tfvar` and update the same with values for all required parameters
- Create the resource by running following commands
  ```bash
  terraform init
  terraform plan
  terraform apply
  ```
- cd into `terraform\separate\aws`
- Update `terraform.tfvar` to add `snowflake_api_aws_iam_user_arn` and `snowflake_api_aws_external_id` from the previous run
- Update the resource by running following commands
  ```bash
  terraform apply
  ```
- This should create and configure all resources in Snowflake and AWS required for external function

## Blog
See this blog for more details

## Terraform commands

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
- https://github.com/aws-samples/amazon-textract-code-samples

# Validate results

```sql
USE SCHEMA DEV_ENTECHLOG_POC_DB.RAW;

SHOW FILE FORMATS;
SHOW INTEGRATIONS;
SHOW STAGES;

LIST @DEMO_S3_STG;

SELECT metadata$filename,
	METADATA$FILE_ROW_NUMBER,
	METADATA$FILE_CONTENT_KEY,
	METADATA$FILE_LAST_MODIFIED,
	METADATA$START_SCAN_TIME,
	$1 AS textract_response
FROM @DEMO_S3_STG(pattern => '.*_detect_doc_response.json');
```

# Future Enhancements

| Feature/Issues                                                                                          | Status |
| ------------------------------------------------------------------------------------------------------- | ------ |
| BucketNotEmpty: The bucket you tried to delete is not empty. You must delete all versions in the bucket | ✔️      |
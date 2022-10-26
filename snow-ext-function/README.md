- [Overview](#overview)
- [Architecture](#architecture)
- [Instructions](#instructions)
  - [Blog](#blog)
  - [Terraform commands](#terraform-commands)
- [Reference](#reference)
- [Testing](#testing)
  - [Commands](#commands)
  - [Payload](#payload)
    - [Lambda](#lambda)
    - [API Gateway](#api-gateway)
- [Tracking Worksheet](#tracking-worksheet)
  - [Step 1: Information about the Lambda Function (remote service)](#step-1-information-about-the-lambda-function-remote-service)
  - [Step 2: Information about the API Gateway (proxy Service)](#step-2-information-about-the-api-gateway-proxy-service)
  - [Step 3: Information about the API Integration and External Function](#step-3-information-about-the-api-integration-and-external-function)
- [Validate results](#validate-results)
- [Future Enhancements](#future-enhancements)
  
# Overview
This repo contains code to create Snowflake External function in AWS using Terraform.

# Architecture
See below diagram for high level architecture

<p align="center">
  <img src="./assets/Snowflake%20external%20function.png" alt="Overview" width="738">
</p>

# Instructions
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
- https://www.youtube.com/watch?v=qangh4oM_zs
- https://docs.snowflake.com/en/sql-reference/external-functions-creating-aws.html
- https://interworks.com/blog/2020/08/14/zero-to-snowflake-setting-up-snowflake-external-functions-with-aws-lambda/
- https://www.startdataengineering.com/post/pull-data-from-api-using-lambda-s3/
- https://mixedanalytics.com/blog/list-actually-free-open-no-auth-needed-apis/
- https://github.com/public-apis/public-apis


# Testing
## Commands

Test the python module locally using `python-lambda-local -f lambda_handler get_weather.py events/example_02.json`

## Payload

### Lambda
```json
{
  "body":
    "{ \"data\": [ [ 0, 43, \"page\" ], [ 1, 42, \"life, the universe, and everything\" ] ] }"
}
```

### API Gateway
```json
{
    "data":
        [
            [0, 43, "page"],
            [1, 42, "life, the universe, and everything"]
        ]
}
```

# Tracking Worksheet

## Step 1: Information about the Lambda Function (remote service)

| Name                 | How to get the details ?                                                                                                                          | Value |
| -------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------- | ----- |
| AWS Account ID       | Login to your AWS account to get the account ID. See [here](https://docs.aws.amazon.com/general/latest/gr/acct-identifiers.html) for more details |       |
| Lambda Function Name | Collect this from lambda_function_name of the Terraform output                                                                                    |       |

## Step 2: Information about the API Gateway (proxy Service)

| Name                        | How to get the details ?                                                                                     | Value |
| --------------------------- | ------------------------------------------------------------------------------------------------------------ | ----- |
| IAM Role Name               | Collect this from iam_role_name of Terraform output                                                          |       |
| IAM Role ARN                | Collect this from iam_role_arn of Terraform output                                                           |       |
| Snowflake Region            | Run the query `select CURRENT_REGION() as current_region` in Snowflake as ACCOUNTADMIN                       |       |
| Snowflake VPC ID (optional) | Run the query `select system$get_snowflake_platform_info() as snowflake_vpc_id` in Snowflake as ACCOUNTADMIN |       |
| API Name                    | Collect this from api_gateway_name of the Terraform output                                                   |       |
| API Gateway Resource Name   |                                                                                                              |       |
| Resource Invocation URL     | Collect this from aws_api_gateway_deployment_invoke_url of Terraform output                                  |       |
| Method Request ARN          | Collect this from api_gateway_execution_arn of the Terraform output                                          |       |

## Step 3: Information about the API Integration and External Function

| Name                   | How to get the details ?                                                  | Value                |
| ---------------------- | ------------------------------------------------------------------------- | -------------------- |
| API Integration Name   | Name of API Gateway integration in Snowflake                              | Example `aws_lambda` |
| API_AWS_IAM_USER_ARN   | Run the query `DESCRIBE integration aws_lambda;` in Snowflake as SYSADMIN |                      |
| API_AWS_EXTERNAL_ID    | Run the query `DESCRIBE integration aws_lambda;` in Snowflake as SYSADMIN |                      |
| External Function Name | Name of external function in Snowflake                                    |                      |

# Validate results

```sql
USE DATABASE <database-name>;
USE SCHEMA <schema-name>;

select demo('100') as demo_result;
select get_weather('kansas'):TEMPERATURE::varchar as current_temperature;
```

# Future Enhancements
- Currently, the module does a force deployment of API gateway using timestamp as trigger. This will end up showing terraform changes on 4 modules all the time. Should find work around to resolve this issue
  ```
    triggers = {
    build_number = timestamp()
  }
  ```

- Add support for external functions with multiple arguments
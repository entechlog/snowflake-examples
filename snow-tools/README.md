- [Overview](#overview)
- [Instructions](#instructions)
- [Tools in this container](#tools-in-this-container)
  - [Snowflake Connector Python](#snowflake-connector-python)
  - [SnowSQL](#snowsql)
  - [Streamlit](#streamlit)
  - [Terraform](#terraform)
  
# Overview
Snowflake tools container contains contains software's which helps to work with Snowflake.

# Instructions
- Bring up the snow-tools container by running
  ```bash
  docker-compose up -d --build
  ```
- Bring up the snow-tools container by running
  ```bash
  docker-compose down -v --remove-orphans
  ```

# Tools in this container

## Snowflake Connector Python

See here for more details on how to use [Snowflake Connector for Python](https://docs.snowflake.com/en/user-guide/python-connector-example.html)

## SnowSQL

See here for more details on how to use [SnowSQL](https://docs.snowflake.com/en/user-guide/snowsql.html)


## Streamlit 

See here for more details on how to use [Streamlit](https://docs.streamlit.io/library/get-started/create-an-app)

## Terraform

Some common commands

```bash
terraform init

terraform fmt

terraform plan

terraform apply
```
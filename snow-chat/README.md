- [Overview](#overview)
- [Architecture](#architecture)
- [Data Warehouse Data Model](#data-warehouse-data-model)
    - [dim\_vendor](#dim_vendor)
    - [dim\_date](#dim_date)
    - [dim\_rate](#dim_rate)
    - [dim\_location](#dim_location)
    - [dim\_payment\_type](#dim_payment_type)
    - [fact\_trip](#fact_trip)
- [Instructions](#instructions)
  - [Load RAW tables](#load-raw-tables)
  - [Load DW tables](#load-dw-tables)
  - [Load DW descriptions](#load-dw-descriptions)
  - [Start the streamlit app](#start-the-streamlit-app)
  - [Clean resources](#clean-resources)
- [Blog](#blog)
- [Reference](#reference)
- [Testing](#testing)
- [Known Issues and Solution](#known-issues-and-solution)
  - [Validate results](#validate-results)
- [Future Enhancements](#future-enhancements)
  
# Overview
This repository contains code that demonstrates the use of ChatGPT to create and query data models in Snowflake.

# Architecture
Refer to the diagram below for a high-level architecture.

<p align="center">
  <img src="./img/Overview.png" alt="Overview" width="738">
</p>

# Data Warehouse Data Model
The model below was generated using the [prompt](./prompts/01_generate_data_model.txt) in a ChatGPT chat session.

### dim_vendor
- vendor_id (PK)
- vendor_code
- vendor_name

### dim_date
- date_id (PK)
- date
- year
- month
- day
- day_name
- month_name
- day_of_week
- day_of_year
- is_weekend
- is_holiday

### dim_rate
- rate_id (PK)
- rate_code
- rate_name

### dim_location
- location_id (PK)
- longitude
- latitude

### dim_payment_type
- payment_type_id (PK)
- payment_type_code
- payment_type_name

### fact_trip
- trip_id (PK)
- vendor_id (FK)
- pickup_date_id (FK)
- dropoff_date_id (FK)
- pickup_location_id (FK)
- dropoff_location_id (FK)
- rate_id (FK)
- payment_type_id (FK)
- passenger_count
- trip_distance
- pickup_timestamp
- dropoff_timestamp
- fare_amount
- extra
- mta_tax
- tip_amount
- tolls_amount
- improvement_surcharge
- total_amount

# Instructions

## Load RAW tables
- Start the [developer-tools](https://github.com/entechlog/developer-tools) container by running `docker-compose up --remove-orphans -d --build`.
- SSH into the container using `docker exec -it developer-tools /bin/bash`.
- Create a new dbt project by running `dbt init snow_chat`. This will prompt you to configure the Snowflake connection for dbt.
  - You can skip this step if you have cloned this repository for the demo.
  - I have also renamed the newly created snow_chat directory to dbt.
- CD into the dbt directory from your code editor (like VSCode) and create a new dbt profile file (profiles.yml). Update it with the database connection details.
- Edit the dbt_project.yml to connect to the profile that we just created. The value for the profile should exactly match the name in profiles.yml (i.e., snow_chat).
- From the developer-tools container and project directory, run dbt-set-profile to update the DBT_PROFILES_DIR. This makes it easier to switch between multiple dbt projects.
- Validate the dbt profile and connection by running `dbt debug`.
- Run `dbt seed` to load the RAW data.

## Load DW tables

- Generate the dbt model SQL files using the [prompt](./prompts/02_generate_dbt_model.txt).
- Copy the ChatGPT-generated dbt models to the dbt project's models directory and run the models using `dbt run`.

## Load DW descriptions
- Generate the dbt schema YAML files using the [prompt](./prompts/03_generate_dbt_schema.txt).
- Copy the ChatGPT-generated dbt schema files to the dbt project's models directory and run the models using `dbt run`.

## Start the streamlit app
- Create a copy of secrets.toml.template in ./streamlit/src/.streamlit/ and rename it to secrets.toml in the same directory. Update it with OpenAI and Snowflake credentials.
- Start the Docker container with miniconda by running `docker-compose -f docker-compose-streamlit.yml up -d --build`.
- Validate the status of Docker containers by running `docker-compose -f docker-compose-streamlit.yml ps`.
- SSH into the miniconda container by running `docker exec -it streamlit /bin/bash`.
- Navigate to [http://localhost:8501/](http://localhost:8501/) to access the streamlit application.

## Clean resources

- Stop the container by running `docker-compose -f docker-compose-streamlit.yml down --volumes --remove-orphans`.

# Blog
Refer to this blog for more details.

# Reference 
- https://www.kaggle.com/datasets/elemento/nyc-yellow-taxi-trip-data?resource=download
- https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf
- https://github.com/darshilparmar/uber-etl-pipeline-data-engineering-project
- https://github.com/fivethirtyeight/data
- https://pythonspeed.com/articles/activate-conda-dockerfile/
  
# Testing

# Known Issues and Solution

| Error                                                                                                                                                                                                                                                     | Solution                                                                                                                          |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------- |
| When testing on a schema with a few hundred tables and columns, the following error occurred: InvalidRequestError: This model's maximum context length is 4097 tokens. However, your messages resulted in 22564 tokens. Please reduce the length of the messages. | You must use a different model which supports more tokens, or logically reduce the tokens before making the API call. |

## Validate results


# Future Enhancements

| Feature | Status |
| ------- | ------ |

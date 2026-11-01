"""
Environment configuration and constants for the data generator
"""

import os

# AWS Configuration
AWS_REGION = os.getenv("AWS_REGION", "us-east-1")

# S3 Configuration
S3_BUCKET = os.getenv("S3_BUCKET_NAME", "entechlog-raw-ext-volume")
S3_WAREHOUSE_PATH = os.getenv("S3_WAREHOUSE_PATH", f"s3://{S3_BUCKET}")

# Glue Configuration
GLUE_DATABASE = os.getenv("GLUE_DATABASE", "faker")

# Schema Configuration
SCHEMA_FILE = os.getenv("SCHEMA_FILE", "schema.yaml")

# Iceberg Write Configuration (shared across all ingestion methods)
ICEBERG_CONFIG_FILE = os.getenv("ICEBERG_CONFIG_FILE", "../iceberg_config.yaml")

# Logging Configuration
LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")

# Generation Configuration
# 0 means use schema default
GENERATION_INTERVAL = int(os.getenv("GENERATION_INTERVAL", "0"))
# 0 means use schema per-table config
BATCH_SIZE_OVERRIDE = int(os.getenv("BATCH_SIZE", "0"))

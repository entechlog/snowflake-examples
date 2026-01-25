"""
Utility modules for the YAML Schema-Based Data Generator with Apache Iceberg
"""

from .config import (
    AWS_REGION,
    S3_BUCKET,
    S3_BASE_PATH,
    S3_PATH_FORMAT,
    S3_WAREHOUSE_PATH,
    GLUE_DATABASE,
    SCHEMA_FILE,
    ICEBERG_CONFIG_FILE,
    LOG_LEVEL,
    GENERATION_INTERVAL,
    BATCH_SIZE_OVERRIDE,
)
from .iceberg_config_loader import (
    load_iceberg_config,
    get_defaults,
    get_partition_column,
    is_schema_evolution_enabled,
    get_namespace_config,
    get_table_config,
    get_source_date_column,
    get_primary_key,
    get_base_path,
    get_path_format,
)
from .logging_setup import setup_logging, get_logger
from .stats import Stats
from .s3_path import format_table_location
from .catalog import init_catalog, get_catalog
from .iceberg import (
    infer_iceberg_type,
    infer_iceberg_type_from_pyarrow,
    build_iceberg_schema,
    build_partition_spec,
    ensure_iceberg_table,
    add_event_date_column,
    write_to_iceberg,
)
from .faker_generator import SchemaBasedGenerator
from .flask_app import create_flask_app

__all__ = [
    # Config
    "AWS_REGION",
    "S3_BUCKET",
    "S3_BASE_PATH",
    "S3_PATH_FORMAT",
    "S3_WAREHOUSE_PATH",
    "GLUE_DATABASE",
    "SCHEMA_FILE",
    "ICEBERG_CONFIG_FILE",
    "LOG_LEVEL",
    "GENERATION_INTERVAL",
    "BATCH_SIZE_OVERRIDE",
    # Iceberg Config Loader
    "load_iceberg_config",
    "get_defaults",
    "get_partition_column",
    "is_schema_evolution_enabled",
    "get_namespace_config",
    "get_table_config",
    "get_source_date_column",
    "get_primary_key",
    "get_base_path",
    "get_path_format",
    # Logging
    "setup_logging",
    "get_logger",
    # Stats
    "Stats",
    # S3 Path
    "format_table_location",
    # Catalog
    "init_catalog",
    "get_catalog",
    # Iceberg
    "infer_iceberg_type",
    "infer_iceberg_type_from_pyarrow",
    "build_iceberg_schema",
    "build_partition_spec",
    "ensure_iceberg_table",
    "add_event_date_column",
    "write_to_iceberg",
    # Generator
    "SchemaBasedGenerator",
    # Flask
    "create_flask_app",
]

"""
Iceberg configuration loader utility.
Loads and provides access to iceberg_config.yaml settings.
Reusable across any data writer (generator, Kafka, API, etc.)
"""

from typing import Dict, Optional
import yaml

from .config import ICEBERG_CONFIG_FILE
from .logging_setup import get_logger

logger = get_logger(__name__)

# Global config cache
_config: Optional[Dict] = None


def load_iceberg_config(config_path: str = None) -> Dict:
    """
    Load Iceberg configuration from YAML file.

    Args:
        config_path: Path to config file. Defaults to ICEBERG_CONFIG_FILE.

    Returns:
        Configuration dictionary.
    """
    global _config

    if _config is not None:
        return _config

    if config_path is None:
        config_path = ICEBERG_CONFIG_FILE

    try:
        with open(config_path, "r") as f:
            _config = yaml.safe_load(f)
            logger.info(f"Loaded Iceberg config from {config_path}")
            return _config
    except Exception as e:
        logger.error(f"Failed to load Iceberg config: {e}")
        raise


def get_defaults() -> Dict:
    """Get default configuration values."""
    config = load_iceberg_config()
    return config.get("defaults", {})


def get_partition_column() -> str:
    """Get the standardized partition column name (default: event_date)."""
    defaults = get_defaults()
    return defaults.get("partition_column", "event_date")


def is_schema_evolution_enabled() -> bool:
    """Check if schema evolution is enabled."""
    defaults = get_defaults()
    return defaults.get("enable_schema_evolution", True)


def get_namespace_config(namespace: str) -> Optional[Dict]:
    """
    Get configuration for a specific namespace.

    Args:
        namespace: Namespace name (e.g., 'faker', 'hubspot').

    Returns:
        Namespace configuration dict or None if not found.
    """
    config = load_iceberg_config()
    namespaces = config.get("namespaces", {})
    return namespaces.get(namespace)


def get_table_config(namespace: str, table_name: str) -> Optional[Dict]:
    """
    Get configuration for a specific table.

    Args:
        namespace: Namespace name (e.g., 'faker').
        table_name: Table name (e.g., 'customers').

    Returns:
        Table configuration dict or None if not found.
    """
    ns_config = get_namespace_config(namespace)
    if ns_config is None:
        return None

    tables = ns_config.get("tables", {})
    return tables.get(table_name)


def get_source_date_column(namespace: str, table_name: str) -> Optional[str]:
    """
    Get the source date column that maps to event_date for a table.

    Args:
        namespace: Namespace name.
        table_name: Table name.

    Returns:
        Source date column name or None if not configured.
    """
    table_config = get_table_config(namespace, table_name)
    if table_config is None:
        return None
    return table_config.get("source_date_column")


def get_primary_key(namespace: str, table_name: str) -> Optional[str]:
    """
    Get the primary key column for a table.

    Args:
        namespace: Namespace name.
        table_name: Table name.

    Returns:
        Primary key column name or None if not configured.
    """
    table_config = get_table_config(namespace, table_name)
    if table_config is None:
        return None
    return table_config.get("primary_key")


def get_base_path(namespace: str) -> Optional[str]:
    """
    Get the base S3 path for a namespace.

    Args:
        namespace: Namespace name.

    Returns:
        Base S3 path or None if not configured.
    """
    ns_config = get_namespace_config(namespace)
    if ns_config is None:
        return None
    return ns_config.get("base_path")

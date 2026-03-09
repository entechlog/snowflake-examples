"""
Glue catalog initialization and management for Iceberg tables
"""

from pyiceberg.catalog import load_catalog
from .config import AWS_REGION, S3_WAREHOUSE_PATH
from .logging_setup import get_logger

logger = get_logger(__name__)

# Global catalog instance
_catalog = None


def init_catalog():
    """
    Initialize PyIceberg catalog with Glue backend.

    Returns:
        The initialized Glue catalog instance.

    Raises:
        Exception: If catalog initialization fails.
    """
    global _catalog
    try:
        _catalog = load_catalog(
            name="glue_catalog",
            **{
                "type": "glue",
                "warehouse": S3_WAREHOUSE_PATH,
                "s3.region": AWS_REGION,
                "glue.region": AWS_REGION,
            },
        )
        logger.info(
            f"Initialized Glue Catalog: warehouse={S3_WAREHOUSE_PATH}, region={AWS_REGION}"
        )
        return _catalog
    except Exception as e:
        logger.error(f"Failed to initialize Glue Catalog: {e}")
        raise


def get_catalog():
    """
    Get the current catalog instance.

    Returns:
        The catalog instance, or None if not initialized.
    """
    return _catalog

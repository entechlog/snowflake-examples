"""
S3 path formatting utilities for custom Iceberg table locations
"""

from .config import S3_BASE_PATH, S3_PATH_FORMAT


def format_table_location(
    namespace: str,
    table_name: str,
    base_path: str = None,
    path_format: str = None,
) -> str:
    """
    Format S3 location for an Iceberg table based on configurable template.

    Args:
        namespace: The database/namespace name (e.g., "faker")
        table_name: The table name (e.g., "products")
        base_path: Base S3 path. Defaults to S3_BASE_PATH from config.
        path_format: Path format template. Defaults to S3_PATH_FORMAT from config.
                    Supports {namespace} and {table} placeholders.

    Returns:
        Full S3 location path for the table.

    Examples:
        >>> format_table_location("faker", "products")
        "s3://bucket/source=faker/event=products"

        >>> format_table_location("faker", "orders", path_format="db={namespace}/tbl={table}")
        "s3://bucket/db=faker/tbl=orders"
    """
    if base_path is None:
        base_path = S3_BASE_PATH
    if path_format is None:
        path_format = S3_PATH_FORMAT

    # Format the path using the template
    formatted_path = path_format.format(namespace=namespace, table=table_name)

    # Ensure no double slashes and proper path construction
    base_path = base_path.rstrip("/")
    formatted_path = formatted_path.lstrip("/")

    return f"{base_path}/{formatted_path}"

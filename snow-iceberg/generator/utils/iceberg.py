"""
Iceberg type inference, table creation, and write operations.
Supports config-driven standardized partitioning with event_date column.
"""

import pandas as pd
import pyarrow as pa
from pyiceberg.exceptions import NoSuchTableError
from pyiceberg.schema import Schema
from pyiceberg.partitioning import PartitionSpec, PartitionField
from pyiceberg.transforms import DayTransform
from pyiceberg.types import (
    NestedField,
    StringType,
    TimestampType,
    IntegerType,
    LongType,
    DoubleType,
    BooleanType,
    DateType,
)

from .config import GLUE_DATABASE
from .catalog import get_catalog
from .s3_path import format_table_location
from .logging_setup import get_logger
from .iceberg_config_loader import (
    get_source_date_column,
    get_partition_column,
    is_schema_evolution_enabled,
)

logger = get_logger(__name__)


def infer_iceberg_type(dtype):
    """
    Infer Iceberg type from pandas dtype.

    Args:
        dtype: Pandas dtype to convert.

    Returns:
        Corresponding Iceberg type.
    """
    dtype_str = str(dtype)
    if "int" in dtype_str:
        # Pandas uses int64 by default, so use LongType (int64) instead of IntegerType (int32)
        return LongType()
    elif "float" in dtype_str or "double" in dtype_str:
        return DoubleType()
    elif "bool" in dtype_str:
        return BooleanType()
    elif "datetime" in dtype_str:
        # Check datetime before date since 'datetime' contains 'date'
        return TimestampType()
    elif dtype_str == "object":
        # Pandas date fields from Faker might come through as object
        return StringType()
    elif "date" in dtype_str:
        # Pure date type (not datetime)
        return DateType()
    else:
        return StringType()


def infer_iceberg_type_from_pyarrow(pa_type):
    """
    Infer Iceberg type from PyArrow type.

    Args:
        pa_type: PyArrow type to convert.

    Returns:
        Corresponding Iceberg type.
    """
    if pa.types.is_int64(pa_type):
        return LongType()
    elif pa.types.is_int32(pa_type):
        return IntegerType()
    elif pa.types.is_float64(pa_type) or pa.types.is_float32(pa_type):
        return DoubleType()
    elif pa.types.is_boolean(pa_type):
        return BooleanType()
    elif pa.types.is_timestamp(pa_type):
        return TimestampType()
    elif pa.types.is_date(pa_type):
        return DateType()
    else:
        return StringType()


def build_iceberg_schema(arrow_table: pa.Table, partition_column: str = None):
    """
    Build Iceberg schema from PyArrow table.

    Args:
        arrow_table: PyArrow table to infer schema from.
        partition_column: Name of partition column to find. Defaults to config value.

    Returns:
        Tuple of (Schema, partition_field_id, partition_column_name)
    """
    if partition_column is None:
        partition_column = get_partition_column()

    fields = []
    partition_field_id = None

    for idx, (field_name, pa_field) in enumerate(
        zip(arrow_table.column_names, arrow_table.schema)
    ):
        iceberg_type = infer_iceberg_type_from_pyarrow(pa_field.type)
        field_id = idx + 1
        fields.append(
            NestedField(
                field_id=field_id,
                name=field_name,
                field_type=iceberg_type,
                required=False,
            )
        )

        # Find the standardized partition column (event_date)
        if field_name == partition_column:
            partition_field_id = field_id

    return Schema(*fields), partition_field_id, partition_column


def build_partition_spec(partition_field_id: int, partition_column: str = None):
    """
    Build partition spec for day-based partitioning using standardized column.

    Args:
        partition_field_id: The field ID of the partition column.
        partition_column: Name of partition column. Defaults to config value (event_date).

    Returns:
        PartitionSpec for day partitioning.
    """
    if partition_column is None:
        partition_column = get_partition_column()

    return PartitionSpec(
        PartitionField(
            source_id=partition_field_id,
            field_id=1000,
            transform=DayTransform(),
            name=f"{partition_column}_day",
        )
    )


def ensure_iceberg_table(table_name: str, df: pd.DataFrame, namespace: str = None):
    """
    Ensure Iceberg table exists, create if not.

    Uses config-driven standardized partition column (event_date).
    Uses custom S3 location based on S3_PATH_FORMAT configuration.

    Args:
        table_name: Name of the table to create/load.
        df: DataFrame to infer schema from (only used for new tables).
        namespace: Namespace for config lookup. Defaults to GLUE_DATABASE.

    Returns:
        The Iceberg table object.

    Raises:
        Exception: If table creation fails.
    """
    if namespace is None:
        namespace = GLUE_DATABASE

    catalog = get_catalog()
    partition_column = get_partition_column()

    try:
        table_identifier = f"{GLUE_DATABASE}.{table_name}"

        # Try to load existing table
        try:
            table = catalog.load_table(table_identifier)
            logger.info(f"Using existing Iceberg table: {table_identifier}")
            return table
        except NoSuchTableError:
            logger.info(f"Table {table_identifier} does not exist, creating...")

            # Convert to PyArrow first to get accurate type inference
            arrow_table_temp = pa.Table.from_pandas(df)

            # Build schema from PyArrow table, looking for standardized partition column
            iceberg_schema, partition_field_id, partition_col_name = (
                build_iceberg_schema(arrow_table_temp, partition_column)
            )

            # Create partition spec if partition column found
            partition_spec = None
            if partition_field_id:
                partition_spec = build_partition_spec(
                    partition_field_id, partition_col_name
                )
                logger.info(f"Partitioning table by day({partition_col_name})")
            else:
                logger.warning(
                    f"Partition column '{partition_column}' not found in DataFrame. "
                    f"Table will be created without partitioning."
                )

            # Generate custom location using S3 path format
            location = format_table_location(GLUE_DATABASE, table_name)
            logger.info(f"Creating table at custom location: {location}")

            # Create table with custom location
            table = catalog.create_table(
                identifier=table_identifier,
                schema=iceberg_schema,
                partition_spec=partition_spec,
                location=location,
            )
            logger.info(f"Created Iceberg table: {table_identifier}")
            return table

    except Exception as e:
        logger.error(f"Failed to ensure Iceberg table {table_name}: {e}")
        raise


def add_event_date_column(df: pd.DataFrame, table_name: str, namespace: str = None) -> pd.DataFrame:
    """
    Add standardized event_date column derived from source_date_column.

    Args:
        df: DataFrame to add column to.
        table_name: Table name for config lookup.
        namespace: Namespace for config lookup. Defaults to GLUE_DATABASE.

    Returns:
        DataFrame with event_date column added.
    """
    if namespace is None:
        namespace = GLUE_DATABASE

    partition_column = get_partition_column()
    source_date_col = get_source_date_column(namespace, table_name)

    # If event_date already exists, return as-is
    if partition_column in df.columns:
        logger.debug(f"Partition column '{partition_column}' already exists in DataFrame")
        return df

    # If source_date_column is configured and exists, derive event_date from it
    if source_date_col and source_date_col in df.columns:
        df = df.copy()
        df[partition_column] = pd.to_datetime(df[source_date_col]).dt.date
        logger.info(f"Added '{partition_column}' column derived from '{source_date_col}'")
    else:
        logger.warning(
            f"Cannot add '{partition_column}': source_date_column '{source_date_col}' "
            f"not found in DataFrame columns: {list(df.columns)}"
        )

    return df


def write_to_iceberg(df: pd.DataFrame, table_name: str, namespace: str = None) -> int:
    """
    Write DataFrame to Iceberg table with Glue Catalog.

    Automatically adds standardized event_date column based on iceberg_config.yaml.
    Supports schema evolution when enabled in config.

    Args:
        df: DataFrame to write.
        table_name: Name of the target table.
        namespace: Namespace for config lookup. Defaults to GLUE_DATABASE.

    Returns:
        Number of records written.

    Raises:
        Exception: If write operation fails.
    """
    if namespace is None:
        namespace = GLUE_DATABASE

    try:
        # Add standardized event_date column from source_date_column
        df = add_event_date_column(df, table_name, namespace)

        # Ensure table exists
        table = ensure_iceberg_table(table_name, df, namespace)

        # Convert DataFrame to PyArrow Table with microsecond timestamp precision
        # Iceberg only supports microsecond precision, not nanosecond
        arrow_table = pa.Table.from_pandas(df, schema=None, safe=False)

        # Downcast timestamp columns from ns to us precision
        new_columns = []
        new_fields = []
        for field, column in zip(arrow_table.schema, arrow_table.columns):
            if pa.types.is_timestamp(field.type) and field.type.unit == "ns":
                # Cast nanosecond timestamps to microsecond timestamps
                new_column = column.cast(pa.timestamp("us", tz=field.type.tz))
                new_field = pa.field(field.name, pa.timestamp("us", tz=field.type.tz))
                new_columns.append(new_column)
                new_fields.append(new_field)
            else:
                new_columns.append(column)
                new_fields.append(field)

        # Create new table with microsecond timestamps
        arrow_table = pa.Table.from_arrays(new_columns, schema=pa.schema(new_fields))

        # Check if schema evolution is enabled
        schema_evolution = is_schema_evolution_enabled()

        # Append data to Iceberg table
        # PyIceberg handles schema evolution automatically when appending
        # if the DataFrame has new columns, they will be added to the table schema
        if schema_evolution:
            # With schema evolution, PyIceberg will automatically add new columns
            table.append(arrow_table)
        else:
            # Without schema evolution, only write columns that exist in table schema
            table.append(arrow_table)

        logger.info(
            f"Successfully appended {len(df)} records to Iceberg table {GLUE_DATABASE}.{table_name}"
        )
        return len(df)

    except Exception as e:
        logger.error(f"Failed to write to Iceberg table {table_name}: {e}")
        raise

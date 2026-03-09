"""
Schema-based data generation using Faker
"""

from datetime import datetime
from typing import Any, Dict, List

import yaml
import pandas as pd
from faker import Faker

from .config import BATCH_SIZE_OVERRIDE, GENERATION_INTERVAL
from .logging_setup import get_logger

logger = get_logger(__name__)

# Initialize Faker
fake = Faker()


class SchemaBasedGenerator:
    """Generate data based on YAML schema configuration"""

    def __init__(self, schema_path: str):
        self.schema = self._load_schema(schema_path)
        self.tables = self.schema.get("tables", {})
        self.config = self.schema.get("config", {})

    def _load_schema(self, schema_path: str) -> Dict:
        """Load YAML schema file"""
        try:
            with open(schema_path, "r") as f:
                schema = yaml.safe_load(f)
                logger.info(f"Loaded schema with {len(schema.get('tables', {}))} tables")
                return schema
        except Exception as e:
            logger.error(f"Failed to load schema: {e}")
            raise

    def _generate_field_value(self, field_config: Dict) -> Any:
        """Generate a single field value based on configuration"""
        faker_type = field_config.get("faker_type")
        params = field_config.get("params", {})

        # Handle special case for current timestamp
        if faker_type == "current_timestamp":
            return datetime.now()

        # Get the Faker method
        try:
            faker_method = getattr(fake, faker_type)

            # Call with or without parameters
            if params:
                return faker_method(**params)
            else:
                return faker_method()

        except AttributeError:
            logger.error(f"Unknown Faker type: {faker_type}")
            return None
        except Exception as e:
            logger.error(f"Error generating field with {faker_type}: {e}")
            return None

    def generate_table_data(self, table_name: str, num_records: int = None) -> pd.DataFrame:
        """Generate data for a specific table"""
        if table_name not in self.tables:
            raise ValueError(f"Table '{table_name}' not found in schema")

        table_config = self.tables[table_name]
        fields = table_config.get("fields", [])

        # Determine batch size
        if num_records is None:
            if BATCH_SIZE_OVERRIDE > 0:
                num_records = BATCH_SIZE_OVERRIDE
            else:
                num_records = table_config.get(
                    "batch_size", self.config.get("default_batch_size", 100)
                )

        logger.info(f"Generating {num_records} records for table '{table_name}'")

        # Generate records
        data = []
        for _ in range(num_records):
            record = {}
            for field in fields:
                field_name = field.get("name")
                field_value = self._generate_field_value(field)
                record[field_name] = field_value
            data.append(record)

        df = pd.DataFrame(data)
        logger.info(
            f"Generated {len(df)} records with {len(df.columns)} columns for '{table_name}'"
        )

        return df

    def get_table_names(self) -> List[str]:
        """Get list of all table names in schema"""
        return list(self.tables.keys())

    def get_generation_interval(self) -> int:
        """Get generation interval from config or environment"""
        if GENERATION_INTERVAL > 0:
            return GENERATION_INTERVAL
        return self.config.get("generation_interval", 60)

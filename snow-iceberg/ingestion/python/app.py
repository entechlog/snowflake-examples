#!/usr/bin/env python3
"""
YAML Schema-Based Data Generator with Apache Iceberg
Generates realistic fake data using Faker and writes as Iceberg tables to S3 with Glue Catalog
"""

import time
import threading
from datetime import datetime

from utils import (
    setup_logging,
    get_logger,
    init_catalog,
    SCHEMA_FILE,
    Stats,
    SchemaBasedGenerator,
    write_to_iceberg,
    create_flask_app,
)

# Initialize logging
setup_logging()
logger = get_logger(__name__)

# Global stats instance
stats = Stats()


def generate_and_upload_all_tables(generator: SchemaBasedGenerator):
    """Generate data for all tables and write to Iceberg"""
    table_names = generator.get_table_names()

    for table_name in table_names:
        try:
            # Generate data
            df = generator.generate_table_data(table_name)

            # Write to Iceberg table
            records_written = write_to_iceberg(df, table_name)

            # Update stats
            stats.add_records(table_name, records_written)

        except Exception as e:
            logger.error(f"Error processing table '{table_name}': {e}")
            stats.increment_errors()


def data_generation_loop(generator: SchemaBasedGenerator):
    """Main loop for continuous data generation"""
    interval = generator.get_generation_interval()
    logger.info(f"Starting data generation loop (interval: {interval}s)")
    logger.info(f"Tables to generate: {', '.join(generator.get_table_names())}")

    while True:
        try:
            logger.info("=" * 80)
            logger.info(f"Starting generation cycle #{stats.cycles + 1} at {datetime.now()}")

            generate_and_upload_all_tables(generator)

            stats.increment_cycle()

            logger.info(f"Cycle complete. Total records: {stats.total_records}")
            logger.info(f"Sleeping for {interval}s")
            logger.info("=" * 80)

            time.sleep(interval)

        except Exception as e:
            logger.error(f"Error in generation loop: {e}")
            stats.increment_errors()
            time.sleep(30)  # Wait before retrying


if __name__ == "__main__":
    # Initialize Iceberg catalog
    try:
        init_catalog()
        logger.info("Iceberg Glue Catalog initialized successfully")
    except Exception as e:
        logger.error(f"Failed to initialize Iceberg catalog: {e}")
        exit(1)

    # Initialize schema-based generator
    try:
        generator = SchemaBasedGenerator(SCHEMA_FILE)
        logger.info(f"Generator initialized with {len(generator.get_table_names())} tables")
    except Exception as e:
        logger.error(f"Failed to initialize generator: {e}")
        exit(1)

    # Create Flask app with stats and generator
    app = create_flask_app(stats, generator)

    # Start data generation in background thread
    generator_thread = threading.Thread(
        target=data_generation_loop, args=(generator,), daemon=True
    )
    generator_thread.start()

    logger.info("Starting Flask app on port 8000")
    app.run(host="0.0.0.0", port=8000, debug=False)

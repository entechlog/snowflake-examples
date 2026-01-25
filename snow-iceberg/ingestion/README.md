# Ingestion Methods

Methods for writing data to Iceberg tables on S3 with Glue catalog.

## Overview

| Method | Source | Glue Database | S3 Path |
|--------|--------|---------------|---------|
| Python Generator | Faker library | `faker` | `source=faker/event={table}/` |
| Kafka Connect | Datagen connector | `datagen` | `source=datagen/event={table}/` |

## Quick Start

### Option 1: Python Generator

```bash
cd ../generator
docker-compose up -d

# Check health
curl http://localhost:8000/health
```

### Option 2: Kafka Connect

```bash
cd kafka-connect
docker-compose up -d

# Connectors auto-deploy. Check status:
curl http://localhost:8083/connectors
```

## Verify in Snowflake

```sql
-- Python Generator data
SELECT * FROM DEV_ENTECHLOG_RAW_DB.FAKER.CUSTOMERS LIMIT 10;

-- Kafka Connect data
SELECT * FROM DEV_ENTECHLOG_RAW_DB.DATAGEN.CUSTOMERS LIMIT 10;
```

## Cleanup

```bash
# Stop Python Generator
cd ../generator && docker-compose down -v

# Stop Kafka Connect
cd kafka-connect && docker-compose down -v
```

# Ingestion Methods

Methods for writing data to Iceberg tables on S3 with Glue catalog.

## Overview

| Method | Source | Glue Database | S3 Path | Snowflake | Details |
|--------|--------|---------------|---------|-----------|---------|
| Python Generator | Faker library | `faker` | `faker.db/{table}/` | Yes | [python/](python/) |
| Kafka Connect | Datagen connector | `datagen` | `datagen.db/{table}/` | Yes | [kafka-connect/](kafka-connect/) |
| Slingdata | PostgreSQL | `slingdata` | `slingdata.db/{table}/` | Athena only | [slingdata/](slingdata/) |

## Quick Start

### Option 1: Python Generator

```bash
cd python
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

### Option 3: Slingdata

```bash
cd slingdata
docker-compose up -d

# Check Glue catalog for tables
aws glue get-tables --database-name slingdata --region us-east-1
```

## Verify in Snowflake

```sql
-- Python Generator data
SELECT * FROM DEV_ENTECHLOG_RAW_DB.FAKER.CUSTOMERS LIMIT 10;

-- Kafka Connect data
SELECT * FROM DEV_ENTECHLOG_RAW_DB.DATAGEN.CUSTOMERS LIMIT 10;

-- Slingdata data (Athena only - see slingdata/README.md for known limitation)
-- SELECT * FROM DEV_ENTECHLOG_RAW_DB.SLINGDATA.CUSTOMERS LIMIT 10;
```

## Cleanup

```bash
# Stop Python Generator
cd python && docker-compose down -v

# Stop Kafka Connect
cd kafka-connect && docker-compose down -v

# Stop Slingdata
cd slingdata && docker-compose down -v
```

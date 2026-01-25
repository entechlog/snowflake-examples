# Python Generator

Generates synthetic data using Faker and writes to S3 Iceberg tables.

## Architecture

```
schema.yaml ──► Python Generator ──► S3 (Iceberg) + Glue Catalog
                + iceberg_config      source=faker/event={table}/
```

## Quick Start

```bash
cd ../../generator
docker-compose up -d

# Check health
curl http://localhost:8000/health

# View stats
curl http://localhost:8000/stats
```

## Configuration

| File | Purpose |
|------|---------|
| `schema.yaml` | Faker field definitions and batch sizes |
| `iceberg_config.yaml` | S3 paths and date column mappings |

## Event Date Mapping

The generator copies source timestamp columns to a standardized `event_date` for partitioning:

| Table | Source Column | Partition |
|-------|---------------|-----------|
| customers | `created_at` | `day(event_date)` |
| orders | `order_date` | `day(event_date)` |
| products | `created_at` | `day(event_date)` |
| event_logs | `event_timestamp` | `day(event_date)` |

## S3 Path Structure

```
s3://bucket/source=faker/event=customers/
├── data/
│   └── created_at_day=YYYY-MM-DD/*.parquet
└── metadata/
    └── *.metadata.json
```

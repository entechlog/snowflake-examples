# Slingdata Iceberg Ingestion

Replicates PostgreSQL tables directly to Iceberg tables in AWS Glue catalog using Sling. No code -- purely config-driven.

## Architecture

```
PostgreSQL (seed data) ──► Sling ──► Iceberg Tables (S3) + Glue Catalog
                                     slingdata.db/{table}/
```

## Components

| Component | Image | Port | Purpose |
|-----------|-------|------|---------|
| PostgreSQL | `postgres:16-alpine` | 5432 | Source database with seed data (50 customers, 200 orders) |
| Sling | `slingdata/sling:latest` | -- | Replicates Postgres to Iceberg via Glue catalog |
| pgAdmin | `dpage/pgadmin4:latest` | 5050 | Web UI for browsing PostgreSQL |

### pgAdmin

Access at `http://localhost:5050`. Login and connection details:

| Setting | Value |
|---------|-------|
| **pgAdmin login email** | `admin@admin.com` |
| **pgAdmin login password** | `admin` |
| **Host** (when adding server) | `postgres` |
| **Port** | `5432` |
| **Database** | `slingdb` |
| **Username** | `sling` |
| **Password** | `sling` |

## Quick Start

### 1. Configure environment

Create `../../.env` with:
```
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
S3_BUCKET_NAME=your-bucket-name
```

### 2. Start the stack

```bash
docker compose up -d
```

Sling waits for PostgreSQL to be healthy, then writes directly to Iceberg tables in Glue.

### 3. Verify

```bash
# Check Glue catalog
aws glue get-tables --database-name slingdata --region us-east-1

# Check S3 data
aws s3 ls s3://your-bucket/slingdata.db/ --recursive
```

## Configuration

| File | Purpose |
|------|---------|
| `sling/env.yaml` | Connection reference (connections are set via env vars in docker-compose) |
| `sling/replication.yaml` | Stream mappings and replication mode |

### Streams

| Source Table | Iceberg Table | Mode |
|-------------|---------------|------|
| `public.customers` | `slingdata.customers` | full-refresh |
| `public.orders` | `slingdata.orders` | full-refresh |

## Known Limitations

Sling's Go-based Iceberg writer (`iceberg-go`) produces manifest files that are **not compatible with Snowflake**. Tables are queryable in Athena but fail in Snowflake with `error 300010`. This is a known issue — the same data re-written by PyIceberg works in Snowflake. See [sling-cli GitHub issue](https://github.com/slingdata-io/sling-cli/issues) for tracking.

For Snowflake-compatible Iceberg ingestion, use the Python generator (`ingestion/python/`) or Kafka Connect (`ingestion/kafka-connect/`).

## Cleanup

```bash
docker compose down -v
```

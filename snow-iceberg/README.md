# Snowflake External Iceberg Tables with S3 + Glue

Query Apache Iceberg tables stored in S3 via AWS Glue Catalog as Snowflake external tables -- RAW data stays in S3, reducing storage cost while Snowflake handles analytics.

## Architecture

```
                                    ┌───────────────────────────────────┐
                                    │          S3 (Iceberg)             │
  Python/Faker ─────────────────►   │  faker.db/{table}/               │  ──► Snowflake
                                    │  datagen.db/{table}/             │      External
  Kafka Connect (Datagen) ──────►   │  slingdata.db/{table}/           │      Iceberg
                                    │                                  │      Tables
  Sling (PostgreSQL) ──────────►    │          Glue Catalog            │  ──► Athena
                                    └───────────────────────────────────┘
```

## Ingestion Methods

| Method | Source | Glue DB | Tables | Snowflake | Details |
|--------|--------|---------|--------|-----------|---------|
| Python Generator | Faker library | `faker` | customers, orders, products, event_logs | Yes | [ingestion/python/](ingestion/python/) |
| Kafka Connect | Datagen connector | `datagen` | customers | Yes | [ingestion/kafka-connect/](ingestion/kafka-connect/) |
| Slingdata | PostgreSQL | `slingdata` | customers, orders | Athena only | [ingestion/slingdata/](ingestion/slingdata/) |

## Key Concepts

- **RAW in S3**: High-volume data stays in S3 as Iceberg tables (Parquet format), avoiding Snowflake managed storage cost
- **Glue Catalog**: AWS Glue Data Catalog manages Iceberg metadata -- no crawlers needed
- **External Iceberg Tables**: Snowflake reads directly from S3 via Glue, zero data duplication
- **Source isolation**: Each ingestion method writes to its own Glue database and Snowflake schema
- **Hidden partitioning**: Iceberg manages partitions in metadata, not directory paths

## Prerequisites

- Docker and Docker Compose
- AWS account with S3, Glue, and Lake Formation access
- Terraform >= 1.0
- Snowflake account

## Getting Started

### 1. Infrastructure Setup

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your Snowflake and AWS settings
# Set create_iceberg_tables = false for first apply

terraform init && terraform apply
```

After first apply, update IAM trust policies (see [Infrastructure Setup](#infrastructure-setup) below), then apply again.

### 2. Run Ingestion

Configure `ingestion/.env` with AWS credentials, then run any method:

```bash
# Python Generator (continuous)
cd ingestion/python && docker-compose up -d

# Kafka Connect (streaming)
cd ingestion/kafka-connect && docker-compose up -d

# Slingdata (batch from PostgreSQL)
cd ingestion/slingdata && docker-compose up -d
```

### 3. Create Snowflake Iceberg Tables

Once data exists in S3, set `create_iceberg_tables = true` in `terraform.tfvars` and re-apply:

```bash
cd terraform && terraform apply
```

### 4. Query in Snowflake

```sql
-- Faker data
SELECT * FROM DEV_ENTECHLOG_RAW_DB.FAKER.CUSTOMERS LIMIT 10;

-- Kafka Connect data
SELECT * FROM DEV_ENTECHLOG_RAW_DB.DATAGEN.CUSTOMERS LIMIT 10;

-- Slingdata data (Athena only - see ingestion/slingdata/README.md for known limitation)
-- SELECT * FROM DEV_ENTECHLOG_RAW_DB.SLINGDATA.CUSTOMERS LIMIT 10;
```

## Infrastructure Setup

The Terraform setup requires multiple applies due to a chicken-and-egg dependency between Snowflake and AWS IAM:

1. **First apply** (`create_iceberg_tables = false`): Creates S3 bucket, IAM roles, Snowflake external volume, catalog integration, and storage integration
2. **Get Snowflake identifiers**: Run `DESC EXTERNAL VOLUME`, `DESC STORAGE INTEGRATION`, and `DESC CATALOG INTEGRATION` in Snowflake to get IAM user ARNs and external IDs
3. **Second apply**: Add the Snowflake identifiers to `terraform.tfvars` and re-apply to update IAM trust policies
4. **Verify**: `SELECT SYSTEM$VERIFY_EXTERNAL_VOLUME('DEV_ENTECHLOG_RAW_EXTERNAL_VOLUME');` should return `SUCCESS`
5. **Configure Lake Formation**: Ensure your IAM user is a Lake Formation admin (`aws lakeformation put-data-lake-settings`)
6. **Third apply** (`create_iceberg_tables = true`): After ingestion runs and data exists in S3, create the Snowflake Iceberg tables

## Cleanup

```bash
# Stop all ingestion
cd ingestion/python && docker-compose down -v
cd ingestion/kafka-connect && docker-compose down -v
cd ingestion/slingdata && docker-compose down -v

# Destroy infrastructure
cd terraform && terraform destroy
```

## References

- [Apache Iceberg](https://iceberg.apache.org/)
- [PyIceberg](https://py.iceberg.apache.org/)
- [Snowflake Iceberg Tables](https://docs.snowflake.com/en/user-guide/tables-iceberg)
- [Snowflake External Volumes](https://docs.snowflake.com/en/sql-reference/sql/create-ext-volume)
- [AWS Glue Data Catalog](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html)
- [Slingdata](https://slingdata.io/)
- [Faker](https://faker.readthedocs.io/)

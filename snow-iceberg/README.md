# Snowflake External Volumes + Iceberg + Glue Demo

**Build cost-effective data lakes with S3 storage and Snowflake analytics**

This demo shows how to use Snowflake External Volumes to query Apache Iceberg tables stored in S3 via AWS Glue Catalog. The RAW data layer stays in S3 (reducing Snowflake storage cost) while Snowflake queries it as external Iceberg tables.

## Architecture

```
YAML Schema → Faker + PyIceberg → Iceberg Tables (S3) + Glue Catalog → Snowflake External Tables
```

**Key components:**
- **RAW layer**: Apache Iceberg tables in S3 (Parquet format)
- **Catalog**: AWS Glue Data Catalog for automatic metadata management
- **Ingestion**: PyIceberg writes data with automatic catalog updates (no crawlers needed)
- **Query**: Snowflake reads RAW via external Iceberg tables
- **DW layer**: Snowflake managed tables for Silver/Gold (via dbt transformation)

**Benefits:**
- **Lower storage cost**: RAW data is stored in S3, avoiding Snowflake managed storage for high-volume RAW/bronze data.
- **Zero ingestion cost**: PyIceberg writes directly to S3, no Snowflake compute charges
- **Automatic catalog**: PyIceberg commits keep Glue in sync (no crawlers needed)
- **Standard format**: Iceberg tables readable by Snowflake, Athena, Spark, etc.

## Quick Reference

| Component | Value |
|-----------|-------|
| **AWS S3 Bucket** | `entechlog-raw-ext-volume` |
| **Glue Database** | `faker` |
| **Snowflake Database** | `DEV_ENTECHLOG_RAW_DB` |
| **Snowflake Schema** | `FAKER` |
| **External Volume** | `DEV_ENTECHLOG_RAW_EXTERNAL_VOLUME` |
| **Catalog Integration** | `DEV_ENTECHLOG_ICEBERG_CATALOG_INT` |
| **Generator Endpoint** | `http://localhost:8000/stats` |
| **Default Tables** | customers, orders, products, event_logs |
| **Generation Interval** | 60 seconds |
| **Records/Cycle** | 850 total (100+200+50+500) |

## Prerequisites

- Docker and Docker Compose
- AWS credentials with S3 access
- Terraform (for AWS infrastructure)
- Snowflake account

## Quick Start

### 1. Verify Prerequisites

```bash
# Check Docker is installed
docker --version
docker compose version

# Check AWS CLI is installed and configured
aws --version
aws sts get-caller-identity

# Set credentials
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_key
export AWS_REGION=us-east-1
```

### 2. Configure Lake Formation Admin (One-time Setup)

**Important:** Your AWS IAM user/role needs to be a Lake Formation admin to grant permissions to Snowflake's IAM role.

```bash
# Get your current IAM identity
aws sts get-caller-identity

# Add yourself as Lake Formation admin (replace with your ARN from above)
aws lakeformation put-data-lake-settings \
  --data-lake-settings '{
    "DataLakeAdmins": [{
      "DataLakePrincipalIdentifier": "arn:aws:iam::ACCOUNT_ID:user/YOUR_USERNAME"
    }]
  }' \
  --region us-east-1

# Verify you're added as admin
aws lakeformation get-data-lake-settings --region us-east-1
```

**Why is this needed?**
- Terraform needs to grant Lake Formation permissions to Snowflake's IAM role
- Only Lake Formation admins can grant these permissions
- This is a one-time setup per AWS account for tf user

### 3. Create AWS and Snowflake Infrastructure (First Apply)

```bash
cd terraform

# Copy and configure terraform.tfvars
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars and set:
# - snowflake_organization_name
# - snowflake_account_name
# - snowflake_username
# - snowflake_password
# - create_iceberg_tables = false  (IMPORTANT - keep false for first run)
# Leave external_volume_*, storage_integration_*, s3_tables_* variables empty for now

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# First apply - creates infrastructure but NOT Snowflake Iceberg tables
terraform apply
```

**Resources created (first apply):**
- AWS S3 bucket: `entechlog-raw-ext-volume` (for Iceberg warehouse)
- AWS Glue Database: `faker`
- AWS IAM user for data generator with Glue write permissions
- AWS IAM roles for Snowflake (with temporary trust policies)
- Snowflake database and FAKER schema
- Snowflake external volume
- Snowflake storage integration
- Snowflake catalog integration (Glue-based for Iceberg)
- Snowflake file format and stage
- ❌ NOT created yet: Snowflake Iceberg tables (waiting for data generator)

### 4. Update IAM Trust Policies

Due to the chicken-and-egg problem (Snowflake needs IAM role, IAM role needs Snowflake external ID), we need a second apply:

```sql
-- In Snowflake, describe the external volume created by Terraform
DESC EXTERNAL VOLUME DEV_ENTECHLOG_RAW_EXTERNAL_VOLUME;

-- Copy these values:
-- STORAGE_AWS_IAM_USER_ARN (starts with arn:aws:iam::)
-- STORAGE_AWS_EXTERNAL_ID (format: ABC123_SFCRole=...)
```

```bash
# Update terraform.tfvars with Snowflake values
cat >> terraform.tfvars <<EOF

# External Volume IAM configuration (from DESC EXTERNAL VOLUME)
external_volume_snowflake_iam_user_arn = "arn:aws:iam::XXX:user/XXX"
external_volume_aws_external_id = "ABC123_SFCRole=XXX"
EOF

# Re-apply to update IAM trust relationships
terraform apply
```

**Verify the connection:**
```sql
SELECT SYSTEM$VERIFY_EXTERNAL_VOLUME('DEV_ENTECHLOG_RAW_EXTERNAL_VOLUME');
-- Should return: [{"status":"SUCCESS"}]
```

### 5. Get Generator AWS Credentials

Terraform created an IAM user for the data generator with permissions to write Iceberg tables:

```bash
# Get the access key ID (in terraform directory)
terraform output iceberg_generator_access_key_id

# Get the secret access key (sensitive output)
terraform output -raw iceberg_generator_secret_access_key
```

### 6. Start Data Generation

Now that infrastructure and credentials are ready, start the generator:

```bash
# Return to project root
cd ..

# Set AWS credentials for the generator
export AWS_ACCESS_KEY_ID=$(cd terraform && terraform output -raw iceberg_generator_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(cd terraform && terraform output -raw iceberg_generator_secret_access_key)

# Start generator in background
docker compose up --build -d

# Check container is running
docker compose ps

# Follow logs
docker compose logs -f generator

# Check health after 10 seconds
sleep 10
curl http://localhost:8000/health

# After first cycle (~60s), check stats
sleep 60
curl http://localhost:8000/stats | jq
```

**Expected stats after first cycle:**
```json
{
  "cycles_completed": 1,
  "total_records": 850,
  "tables": {
    "customers": {"records": 100, "batches": 1},
    "orders": {"records": 200, "batches": 1},
    "products": {"records": 50, "batches": 1},
    "event_logs": {"records": 500, "batches": 1}
  }
}
```

### 7. Verify Data in S3 and Glue

After the generator runs for a minute, verify the Iceberg tables were created:

```bash
# List Iceberg data (new path format: source={namespace}/event={table})
aws s3 ls s3://entechlog-raw-ext-volume/source=faker/ --recursive

# Check Glue catalog for tables
aws glue get-tables --database-name faker --region us-east-1

# Get details of customers table
aws glue get-table --database-name faker --name customers --region us-east-1
```

Expected output: You should see `customers`, `orders`, `products`, and `event_logs` tables registered in Glue Catalog with Iceberg table format.

### 8. Create Snowflake Iceberg Tables (Third Apply)

Now that data exists in S3, create the Snowflake Iceberg tables:

```bash
cd terraform

# Update terraform.tfvars - change the flag to true
# Edit terraform.tfvars and set:
# create_iceberg_tables = true

# Or use sed:
sed -i 's/create_iceberg_tables = false/create_iceberg_tables = true/' terraform.tfvars

# Third apply - creates Snowflake Iceberg tables
terraform apply
```

This creates **external** Iceberg tables in Snowflake that reference the Glue Catalog:
- `DEV_ENTECHLOG_RAW_DB.FAKER.CUSTOMERS` → Iceberg table in S3
- `DEV_ENTECHLOG_RAW_DB.FAKER.ORDERS` → Iceberg table in S3
- `DEV_ENTECHLOG_RAW_DB.FAKER.PRODUCTS` → Iceberg table in S3
- `DEV_ENTECHLOG_RAW_DB.FAKER.EVENT_LOGS` → Iceberg table in S3

These tables don't store data in Snowflake - they read directly from S3 Iceberg tables via Glue Catalog.

### 9. Query Iceberg Tables from Snowflake

Query the Iceberg tables directly - Snowflake reads from S3 via Glue Catalog:

```sql
-- Use the warehouse
USE WAREHOUSE COMPUTE_WH;

-- Query Iceberg tables (data stored in S3, queried through Glue Catalog)
SELECT * FROM DEV_ENTECHLOG_RAW_DB.FAKER.CUSTOMERS LIMIT 10;
SELECT * FROM DEV_ENTECHLOG_RAW_DB.FAKER.ORDERS LIMIT 10;
SELECT * FROM DEV_ENTECHLOG_RAW_DB.FAKER.PRODUCTS LIMIT 10;
SELECT * FROM DEV_ENTECHLOG_RAW_DB.FAKER.EVENT_LOGS LIMIT 10;

-- Describe the Iceberg table structure
DESCRIBE TABLE DEV_ENTECHLOG_RAW_DB.FAKER.CUSTOMERS;

-- Show table properties (confirms it's an external Iceberg table)
SHOW ICEBERG TABLES IN SCHEMA DEV_ENTECHLOG_RAW_DB.FAKER;

-- Count records across all tables
SELECT 'customers' as table_name, COUNT(*) as count FROM DEV_ENTECHLOG_RAW_DB.FAKER.CUSTOMERS
UNION ALL
SELECT 'orders', COUNT(*) FROM DEV_ENTECHLOG_RAW_DB.FAKER.ORDERS
UNION ALL
SELECT 'products', COUNT(*) FROM DEV_ENTECHLOG_RAW_DB.FAKER.PRODUCTS
UNION ALL
SELECT 'event_logs', COUNT(*) FROM DEV_ENTECHLOG_RAW_DB.FAKER.EVENT_LOGS;
```

**Create Snowflake Managed Tables (Silver/Gold layer):**

Use the RAW Iceberg tables as source for transformed data in Snowflake:

```sql
-- Example: Create a managed table with transformed customer data
SELECT
    customer_id,
    CONCAT(first_name, ' ', last_name) as full_name,
    email,
    phone,
    city,
    state,
    account_status,
    created_at,
    CURRENT_TIMESTAMP() as loaded_at
FROM DEV_ENTECHLOG_RAW_DB.FAKER.CUSTOMERS;
```

## Iceberg Partitioning

### How it differs from Hive partitioning

**Traditional Hive Partitioning** (what you may be used to):
```
s3://bucket/source=faker/event_name=orders/year=2025/month=01/dd=01/file.parquet
```
- Partition columns in directory names
- Manual folder structure management
- Partition values duplicated in paths AND data
- Requires Glue Crawler to discover new partitions
- Renaming partitions requires moving files

**Iceberg Hidden Partitioning** (automatic with this demo):
```
s3://bucket/source=faker/event=orders/data/
├── 00000-0-abc123.parquet  (contains data for 2025-01-01)
├── 00001-0-def456.parquet  (contains data for 2025-01-02)
└── metadata/
    ├── v1.metadata.json    (partition info stored here)
    └── snap-123.avro
```
- **No partition folders** - data files in single directory
- Partition info stored in Iceberg metadata, not paths
- Automatic partition pruning by query engines
- Can change partitioning scheme without rewriting data

### Automatic Partitioning in this Demo

The generator automatically partitions tables by the **first timestamp column** it finds:

```python
# For customers table with created_at timestamp:
# Automatically partitions by day(created_at)

# Snowflake query automatically uses partition pruning:
SELECT * FROM customers WHERE created_at = '2025-01-01';
-- Only scans files for that day!
```

**Benefits:**
- ✅ No manual partition folder creation
- ✅ Glue Catalog stays in sync automatically (via PyIceberg commits)
- ✅ Query performance benefits without folder complexity
- ✅ Can evolve partition scheme later (year → month → day)

### Querying Partitioned Tables

```sql
-- Snowflake uses Iceberg metadata for partition pruning
SELECT * FROM DEV_ENTECHLOG_RAW_DB.FAKER.ORDERS
WHERE order_date BETWEEN '2025-01-01' AND '2025-01-31';
-- Automatically scans only January data files

-- Check partition metadata
DESC TABLE DEV_ENTECHLOG_RAW_DB.FAKER.ORDERS;
```

## Source System Naming Convention

**Important:** Source names should represent the **actual source system**, not technology or domain.

### ✅ Good Source Names:
- `faker` - Fake data generator (this demo)
- `hubspot` - HubSpot CRM
- `salesforce` - Salesforce
- `stripe` - Stripe payments
- `billing_db` - Internal billing database
- `customer_portal_db` - Customer portal database
- `inventory_db` - Inventory database

### ❌ Bad Source Names:
- `postgres` - Technology name (what DB engine, not which system)
- `mysql` - Technology name
- `sales` - Domain/subject area (not a source system)
- `marketing` - Domain/subject area
- `raw` - Layer name (not a source system)

### Architecture with Source Naming:
```
Source System: faker (the data generator)
├── Glue Database: faker (matches source)
├── Snowflake Schema: FAKER (matches source)
└── Tables within faker:
    ├── customers
    ├── orders
    ├── products
    └── event_logs
```

**For multiple sources** (if you extend this demo):
```
S3 Bucket:
├── source=faker/              # Source: faker data generator
│   ├── event=customers/
│   └── event=orders/
├── source=hubspot/            # Source: HubSpot CRM
│   ├── event=contacts/
│   └── event=deals/
└── source=billing_db/         # Source: internal billing database
    ├── event=invoices/
    └── event=payments/
```

## Customizing Data Generation

### Edit Schema

The easiest way to customize is by editing `generator/schema.yaml`:

```yaml
tables:
  my_new_table:
    description: "My custom table"
    batch_size: 150
    fields:
      - name: id
        faker_type: uuid4
      - name: name
        faker_type: name
      - name: email
        faker_type: email
      - name: age
        faker_type: random_int
        params:
          min: 18
          max: 80
```

Available Faker types: https://faker.readthedocs.io/en/master/providers.html

### Configuration Options

Edit `docker-compose.yml` to change generation behavior:

```yaml
environment:
  - GENERATION_INTERVAL=120                                  # Generate every 2 minutes
  - BATCH_SIZE=500                                           # Override all table batch sizes
  - S3_BASE_PATH=s3://my-bucket                              # Base S3 path for Iceberg tables
  - S3_PATH_FORMAT=source={namespace}/event={table}          # Path format template
  - S3_WAREHOUSE_PATH=s3://my-bucket/warehouse               # Glue catalog warehouse location
  - GLUE_DATABASE=my_database                                # Change Glue database name
  - LOG_LEVEL=DEBUG                                          # More detailed logging
```

## Monitoring

### Health Check
```bash
curl http://localhost:8000/health
```

Returns:
```json
{
  "status": "healthy",
  "uptime_seconds": 125.45,
  "cycles_completed": 2,
  "total_records": 1700,
  "errors": 0
}
```

### Statistics
```bash
curl http://localhost:8000/stats
```

Returns detailed per-table statistics:
```json
{
  "total_records": 1700,
  "cycles_completed": 2,
  "records_per_second": 13.55,
  "tables": {
    "customers": {"records": 200, "batches": 2},
    "orders": {"records": 400, "batches": 2}
  }
}
```

### View Logs
```bash
# Follow logs in real-time
docker compose logs -f generator

# View last 100 lines
docker compose logs --tail=100 generator
```

## Data Schema

### Default Tables

**customers** (100 records/batch):
- customer_id, name, email, phone
- address, city, state, zip, country
- registration_date, account_status

**orders** (200 records/batch):
- order_id, customer_id, order_date
- order_amount, currency, payment_method
- shipping details, items_count

**products** (50 records/batch):
- product_id, product_name, category, brand
- price, cost, stock_quantity
- sku, weight, dimensions, rating

**event_logs** (500 records/batch):
- event_id, user_id, session_id
- event_type, timestamp, page_url
- user_agent, ip_address, device_type

## File Structure

```
.
├── generator/
│   ├── app.py              # Main entry point
│   ├── schema.yaml         # Table and field definitions
│   ├── Dockerfile
│   ├── requirements.txt
│   └── utils/              # Modular utility components
│       ├── __init__.py     # Module exports
│       ├── config.py       # Environment configuration
│       ├── logging_setup.py
│       ├── stats.py        # Statistics tracking
│       ├── s3_path.py      # S3 path formatting (source={namespace}/event={table})
│       ├── catalog.py      # Glue catalog initialization
│       ├── iceberg.py      # Iceberg operations
│       ├── faker_generator.py  # Data generation
│       └── flask_app.py    # Health/stats endpoints
├── terraform/
│   ├── aws_*.tf            # AWS resources (S3, IAM, Glue, Lake Formation)
│   ├── snowflake_*.tf      # Snowflake resources (external volumes, Iceberg tables)
│   ├── variables.tf        # Input variables
│   ├── outputs.tf          # Outputs (credentials, ARNs)
│   └── terraform.tfvars.example
├── docker-compose.yml      # Docker orchestration
├── .gitignore
└── README.md
```

## Troubleshooting

### Generator not starting
```bash
# Check logs
docker compose logs generator

# Verify AWS credentials
docker compose exec generator env | grep AWS
```

### No data in Glue Catalog
```bash
# Check generator stats
curl http://localhost:8000/stats

# Verify Glue permissions
aws glue get-tables --database-name faker

# Check S3 data location
aws s3 ls s3://entechlog-raw-ext-volume/source=faker/ --recursive
```

### Snowflake can't read Iceberg tables
```sql
-- Verify catalog integration
DESC CATALOG INTEGRATION DEV_ENTECHLOG_ICEBERG_CATALOG_INT;

-- Check external volume
SELECT SYSTEM$VERIFY_EXTERNAL_VOLUME('DEV_ENTECHLOG_RAW_EXTERNAL_VOLUME');

-- List Iceberg tables
SHOW ICEBERG TABLES IN SCHEMA DEV_ENTECHLOG_RAW_DB.FAKER;
```

### PyIceberg errors in generator logs
```bash
# Check generator logs for Glue/S3 permission errors
docker compose logs generator | grep -i error

# Verify IAM permissions
aws sts get-caller-identity
aws iam get-user --user-name dev-entechlog-iceberg-generator
```

## Cleanup

```bash
# Stop services
docker compose down

# Remove volumes
docker compose down -v

# Destroy AWS infrastructure
cd terraform
terraform destroy
```

## Next Steps

- **Add more tables**: Edit `schema.yaml` to generate additional data
- **dbt transformation**: Build Silver/Gold layers in Snowflake using dbt
- **Incremental updates**: Modify generator for append-only or merge patterns
- **Partitioning**: Add partition transforms to Iceberg tables for better performance
- **Time travel**: Explore Iceberg snapshot features
- **BI integration**: Connect Preset/Superset to Snowflake managed tables
- **Data quality**: Add checks using dbt tests or Great Expectations

## Why This Architecture?

**Cost optimization:**
- Storage: ~40% cheaper in S3 vs Snowflake
- Ingestion: $0 (PyIceberg writes directly, no Snowflake compute)
- Query: Pay only when running queries in Snowflake

**Flexibility:**
- Query data from Snowflake, Athena, Spark, or Trino
- Standard Iceberg format prevents vendor lock-in
- No Glue Crawlers needed (PyIceberg auto-updates catalog)

## References

- [Faker Documentation](https://faker.readthedocs.io/)
- [PyIceberg Documentation](https://py.iceberg.apache.org/)
- [Apache Iceberg](https://iceberg.apache.org/)
- [AWS Glue Data Catalog](https://docs.aws.amazon.com/glue/latest/dg/catalog-and-crawler.html)
- [Snowflake Iceberg Tables](https://docs.snowflake.com/en/user-guide/tables-iceberg)
- [Snowflake External Volumes](https://docs.snowflake.com/en/sql-reference/sql/create-ext-volume)

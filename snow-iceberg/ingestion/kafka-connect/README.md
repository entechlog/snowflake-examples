# Kafka Connect Iceberg Ingestion

Writes streaming data to S3 Iceberg tables using Kafka Connect.

## Architecture

```
Datagen Source ──► Kafka Topic ──► Iceberg Sink ──► S3 (Iceberg) + Glue Catalog
                   datagen.customers              source=datagen/event=customers/
```

## Components

| Component | Port | Purpose |
|-----------|------|---------|
| Zookeeper | 2181 | Kafka coordination |
| Kafka | 9092 | Message broker |
| Schema Registry | 8081 | Avro schema management |
| Kafka Connect | 8083 | Connector runtime |
| Kafka UI | 8080 | Web UI for debugging |

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
docker-compose up -d
```

Connectors deploy automatically when Kafka Connect is healthy.

### 3. Verify

```bash
# Check connector status
curl -s http://localhost:8083/connectors/datagen-customers/status
curl -s http://localhost:8083/connectors/iceberg-sink-customers/status

# View Kafka UI
open http://localhost:8080
```

## S3 Path Structure

Data writes to custom paths via `write.data.path` and `write.metadata.path`:

```
s3://bucket/source=datagen/event=customers/
├── data/
│   └── *.parquet
└── metadata/
    ├── *.metadata.json
    └── *.avro
```

## Connector Configuration

### Datagen Source (`datagen-customers.json`)
- Generates synthetic user data using `quickstart: users`
- Publishes to `datagen.customers` topic

### Iceberg Sink (`iceberg-sink-customers.json`)
- Consumes from `datagen.customers` topic
- Auto-creates Iceberg table in Glue catalog (`datagen.customers`)
- Uses `CopyValue` SMT to copy `registertime` to `event_date`
- Partitions by `day(event_date)`
- Commits every 60 seconds

Key settings:
```json
{
  "iceberg.tables.auto-create-props.write.data.path": "s3://bucket/source=datagen/event=customers/data",
  "iceberg.tables.auto-create-props.write.metadata.path": "s3://bucket/source=datagen/event=customers/metadata",
  "transforms.addEventDate.type": "org.apache.iceberg.connect.transforms.CopyValue",
  "iceberg.table.datagen.customers.partition-by": "day(event_date)"
}
```

## Useful Commands

### Connector Status
```bash
curl -s http://localhost:8083/connectors
curl -s http://localhost:8083/connectors/iceberg-sink-customers/status
```

### Restart Connector
```bash
curl -X POST http://localhost:8083/connectors/iceberg-sink-customers/restart
```

### View Logs
```bash
docker logs kafka-connect -f
docker logs kafka-connect 2>&1 | grep -i error
```

### Kafka Topics
```bash
docker exec kafka kafka-topics --bootstrap-server kafka:29092 --list
```

## Cleanup

```bash
docker-compose down -v
```

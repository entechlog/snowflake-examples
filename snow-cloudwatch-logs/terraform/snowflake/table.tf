resource "snowflake_table" "this" {
  database = snowflake_database.this.name
  schema   = snowflake_schema.this.name
  name     = "CWL_LAMBDA"

  column {
    name     = "file_name"
    type     = "text"
    nullable = false

  }

  column {
    name     = "file_row_number"
    type     = "NUMBER(38,0)"
    nullable = false

  }

  column {
    name     = "file_content_key"
    type     = "text"
    nullable = true
  }

  column {
    name = "file_last_modified"
    type = "TIMESTAMP_NTZ(9)"
  }

  column {
    name = "cloudwatch_log"
    type = "VARIANT"
  }

}

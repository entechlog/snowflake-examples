
// Output block starts here

output "raw_db_name" {
  value = module.raw_db.database.name
}

output "raw_db_schemas" {
  value = join(", ", [for schema in values(module.raw_db.schema) : schema.name])
}

output "prep_db_name" {
  value = module.prep_db.database.name
}

output "prep_db_schemas" {
  value = join(", ", [for schema in values(module.prep_db.schema) : schema.name])
}

output "dw_db_name" {
  value = module.dw_db.database.name
}

output "dw_db_schemas" {
  value = join(", ", [for schema in values(module.dw_db.schema) : schema.name])
}
output "tenant_db_name" {
  description = "Database name for the tenant"
  value       = google_sql_database.tenant_db.name
}

output "tenant_db_user" {
  description = "Database user for the tenant"
  value       = google_sql_user.tenant_user.name
}
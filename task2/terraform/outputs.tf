output "secret_name" {
  description = "GCP Secret Manager secret name"
  value       = google_secret_manager_secret.tenant_secret.secret_id
}

output "service_account_email" {
  description = "GCP Service Account email"
  value       = google_service_account.tenant_sa.email
}
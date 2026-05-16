variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
  default     = "asia-south1"
}

variable "cloud_sql_instance" {
  description = "Cloud SQL Instance name"
  type        = string
}

variable "db_name" {
  description = "Database name for the tenant"
  type        = string
}

variable "db_user" {
  description = "Database user for the tenant"
  type        = string
}

variable "db_password" {
  description = "Database password for the tenant"
  type        = string
  sensitive   = true
}

variable "tenant_name" {
  description = "Tenant name"
  type        = string
}
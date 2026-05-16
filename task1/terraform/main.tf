terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }

  }
}
provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_sql_user" "tenant_user" {
  name     = var.db_user
  instance = var.cloud_sql_instance
  password = var.db_password
}

resource "google_sql_database" "tenant_db" {
  name     = var.db_name
  instance = var.cloud_sql_instance
}
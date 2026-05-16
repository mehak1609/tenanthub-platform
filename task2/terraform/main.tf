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

# Har tenant ka alag secret GCP Secret Manager 
resource "google_secret_manager_secret" "tenant_secret" {
  secret_id = "tenant-${var.tenant_name}-credentials"

  replication {
    auto {}
  }
}

# Store secret actul value
resource "google_secret_manager_secret_version" "tenant_secret_version" {
  secret = google_secret_manager_secret.tenant_secret.id
  secret_data = jsonencode({
    db_name     = var.db_name
    db_user     = var.db_user
    db_password = var.db_password
  })
}

# GCP Service Account for tenant
resource "google_service_account" "tenant_sa" {
  account_id   = "tenant-${var.tenant_name}-sa"
  display_name = "Service Account for tenant ${var.tenant_name}"
}

# Access of my account
resource "google_secret_manager_secret_iam_binding" "tenant_secret_access" {
  secret_id = google_secret_manager_secret.tenant_secret.secret_id
  role      = "roles/secretmanager.secretAccessor"
  members = [
    "serviceAccount:${google_service_account.tenant_sa.email}"
  ]
}

# Workload Identity — K8s ServiceAccount ko GCP SA se bind krte hn

resource "google_service_account_iam_binding" "workload_identity" {
  service_account_id = google_service_account.tenant_sa.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[${var.tenant_name}/${var.tenant_name}-sa]"
  ]
}
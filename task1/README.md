# Task 1 — Tenant Provisioning

## Overview
This task automates the full provisioning flow for onboarding a new tenant (acme-corp) 
onto the TenantHub SaaS platform.


## Components

### 1. Terraform Module
- Provisions a dedicated PostgreSQL database and user for the tenant
- Uses GCP Cloud SQL instance
- All resources are idempotent — running twice will not create duplicates


### 2. Kubernetes Manifests
- **Namespace** — dedicated `acme-corp` namespace for isolation
- **ServiceAccount** — tenant-specific service account
- **Role** — read-only access scoped only to tenant's own secrets
- **RoleBinding** — binds the Role to the ServiceAccount


### 3. GitHub Actions Workflow
- Triggered automatically when a new row is added to `tenants.yaml`
- Runs Terraform to provision the database
- Creates Kubernetes namespace and RBAC
- Opens a Pull Request with all changes


## Idempotency
If the workflow is run twice for the same tenant:
- Terraform uses `resource` blocks which check existing state — 
  if the database and user already exist, no changes are made
- `kubectl apply` is declarative — applying the same manifest 
  twice has no effect
- The GitHub Actions workflow is safe to re-run at any time


## Scaling to 50 Tenants
To scale to 50 tenants without editing the workflow:
- Simply add new rows to `tenants.yaml`
- The workflow loops through all tenants automatically
- Each tenant gets their own database, namespace, and RBAC
- No changes needed to the workflow itself
# TenantHub Platform Infrastructure

## About
This repo contains my solution for the Crego DevOps engineering assignment.


The scenario: I'm the first Platform Engineer at TenantHub, a fintech SaaS 
company, and I need to build the foundational infrastructure from scratch.

## What I Built

### Task 1 - Tenant Provisioning
When a new client joins, everything should provision automatically.
I automated this using:
- **Terraform** to create a dedicated Cloud SQL database and user per tenant
- **Kubernetes manifests** for namespace isolation and RBAC
- **GitHub Actions** workflow that triggers when tenants.yaml is updated

The whole flow is idempotent - running it twice won't break anything.

### Task 2 - Secret Isolation
The existing setup had all tenants sharing one secret — a serious risk.
I fixed this by:
- Moving secrets to **GCP Secret Manager** with one secret per tenant
- Using **Workload Identity** so pods authenticate without storing credentials
- Scoping **IAM bindings** to only that tenant's secret — not project-wide
- Writing a **NetworkPolicy** so pods can only reach DNS and their own database

### Task 3 - Infra Change Visibility
The team had no way to see what would change before merging a PR.
I added:
- A **PR diff workflow** that comments the exact Kubernetes resource diff on every PR
- An **ArgoCD notification** that sends a Slack alert when any app goes Degraded or OutOfSync

## Tech Stack
Kubernetes · Terraform · GCP · GitHub Actions · ArgoCD · Kustomize · External Secrets Operator

## Note
No live GCP account was used — as per assignment instructions.
All Terraform and Kustomize outputs are included as static files.


## Note on GitHub Actions
The tenant-provisioning workflow will show as failed in CI because 
no live GCP credentials are configured — as per assignment instructions 
which state "No live cloud account required". The workflow code is 
correct and would work with real GCP credentials injected as GitHub Secrets.
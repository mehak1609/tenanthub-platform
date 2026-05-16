# Task 1 — Tenant Provisioning

## What I Was Trying to Solve
When a new client (tenant) joins TenantHub, someone has to manually 
create a database, set up Kubernetes resources, and configure permissions.
This is slow, error-prone, and doesn't scale. I wanted to make this 
fully automatic — just add a row to tenants.yaml and everything 
provisions itself.

## What I Built

### Terraform Module
I wrote a Terraform module that creates a dedicated PostgreSQL database 
and user for each tenant inside an existing Cloud SQL instance. 
The resources are idempotent — if the workflow runs twice for the same 
tenant, Terraform detects that the resources already exist and makes 
no changes.

### Kubernetes Manifests
I created three resources per tenant:
- **Namespace** — gives the tenant a completely isolated space on the cluster
- **Role** — grants read-only access to only that tenant's own secret,
  nothing else
- **RoleBinding** — connects the Role to the tenant's ServiceAccount

### GitHub Actions Workflow
The workflow triggers automatically when a new row is added to 
tenants.yaml. It runs Terraform, applies the Kubernetes manifests, 
and opens a Pull Request with all the changes. It is safe to re-run.

## Idempotency
If the workflow runs twice for the same tenant:
- Terraform checks existing state — no duplicate resources are created
- kubectl apply is declarative — same manifest applied twice = no change
- The PR step uses the same branch name, so it updates the existing PR

## Scaling to 50 Tenants
To onboard 50 tenants, I would loop over all entries in tenants.yaml 
using a matrix strategy in GitHub Actions. Each tenant gets processed 
independently. No changes needed to the workflow itself — just add 
rows to tenants.yaml.
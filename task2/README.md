# Task 2 — Secret Isolation & Security

## What I Was Trying to Solve
The existing setup had all tenants sharing a single Kubernetes Secret 
called app-env. This meant any pod could read any tenant's database 
credentials — a serious security risk in a fintech environment where 
data isolation is critical.

I wanted to ensure each tenant can only ever access their own secrets,
nothing else.

## What I Built

### Per-Tenant Secrets in GCP Secret Manager
Instead of one shared Kubernetes Secret, I created a dedicated secret 
in GCP Secret Manager for each tenant — for example,
tenant-acme-corp-credentials. This stores the tenant's DB name, 
user, and password as a JSON object.

### Workload Identity
I didn't want to store GCP credentials inside the cluster. Instead,
I used Workload Identity to bind the Kubernetes ServiceAccount to a 
GCP Service Account. This way, pods authenticate to GCP automatically 
without any stored keys.

### Scoped IAM Binding
The GCP Service Account gets roles/secretmanager.secretAccessor — but 
scoped only to that tenant's single secret, not the entire project.
Even if a tenant's pod is compromised, the attacker can only read that 
one secret — not every tenant's credentials.

### ExternalSecret
I used External Secrets Operator to automatically sync the GCP secret 
into the tenant's Kubernetes namespace as a native Secret. It refreshes 
every hour so any credential rotation is picked up automatically.

### NetworkPolicy
I wrote a NetworkPolicy that denies all egress by default, and only 
allows two things:
- Cluster DNS (port 53) — so the pod can resolve hostnames
- Its own database (port 5432) — nothing else

## Security Analysis

### What attack does scoped IAM prevent?
Without scoping, a compromised pod with access to the GCP Service Account 
could read every tenant's credentials across the entire project — a 
complete data breach. By scoping the IAM binding to a single secret, 
I limit the blast radius. Even in a worst-case compromise, only one 
tenant's data is at risk.

### Why is NetworkPolicy alone not enough?
NetworkPolicy only controls network traffic. It doesn't prevent a 
misconfigured pod from reading another tenant's Kubernetes Secrets 
if RBAC isn't set up correctly. It also doesn't prevent resource 
exhaustion — one tenant could consume all cluster CPU/memory and 
starve others. Real tenant isolation needs NetworkPolicy + RBAC + 
scoped IAM + resource quotas working together.
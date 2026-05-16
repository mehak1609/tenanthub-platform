# Task 2 — Secret Isolation & Security

## Overview
This task fixes a critical security vulnerability where all tenants 
shared one Kubernetes Secret. Now each tenant has completely isolated 
secrets with scoped access.

## Components

### 1. GCP Secret Manager (Terraform)
- Each tenant gets a dedicated secret: `tenant-acme-corp-credentials`
- Stores DB name, user, and password as JSON
- No shared secrets between tenants

### 2. Workload Identity (Terraform)
- A dedicated GCP Service Account is created per tenant
- The Kubernetes ServiceAccount is annotated to bind to the GCP SA
- This allows pods to authenticate to GCP without storing credentials

### 3. IAM Binding (Terraform)
- The GCP Service Account gets `roles/secretmanager.secretAccessor`
- Scoped ONLY to that tenant's secret — not the whole project
- Even if one tenant is compromised, others remain safe

### 4. ExternalSecret (Kubernetes)
- External Secrets Operator syncs the GCP secret into the namespace
- Creates a native Kubernetes Secret `acme-corp-credentials`
- Refreshes every 1 hour automatically

### 5. NetworkPolicy (Kubernetes)
- Denies ALL egress by default
- Allows only: cluster DNS (port 53) and own database (port 5432)
- Tenant pods cannot reach other tenants' databases

## Security Analysis

### What attack is prevented by scoping IAM to a single secret?

By binding the IAM role `roles/secretmanager.secretAccessor` to only 
`tenant-acme-corp-credentials` instead of the entire project, we prevent 
a **privilege escalation / lateral movement attack**.

If a tenant's pod is compromised and an attacker gains access to the 
GCP Service Account, they can only read that one tenant's secret. 
Without scoping, the same compromised account could read ALL tenants' 
database credentials across the entire project — a complete data breach. 
Scoped IAM enforces the **principle of least privilege**: every identity 
gets only the minimum permissions it needs.

### Why is NetworkPolicy alone not sufficient for tenant isolation?

NetworkPolicy controls **network-level traffic** but does not address 
other isolation concerns in a shared Kubernetes cluster. A malicious 
or misconfigured pod could still:

- Read another tenant's Kubernetes Secrets if RBAC is not configured
- Access shared cluster resources like ConfigMaps or ServiceAccounts
- Consume excessive CPU/memory, starving other tenants (no resource quotas)
- Exploit Kubernetes API server vulnerabilities

True tenant isolation requires a **defence-in-depth approach**: 
NetworkPolicy + RBAC + scoped IAM + resource quotas + separate 
namespaces — all working together.
# Task 3 — Infra Change Visibility

## Overview
This task solves two problems:
1. Team merges PRs without knowing what Kubernetes resources will change
2. No alerting when deployments break in ArgoCD

## Components

### 1. PR Diff Workflow (GitHub Actions)
Every PR to the infra repo automatically:
- Builds Kustomize output for both PR branch and main branch
- Diffs the two outputs
- Posts the diff as a PR comment so reviewers can see exactly
  what Kubernetes resources will change before merging

### 2. ArgoCD Notifications (Slack Alert)
- Sends a Slack message to `#devops-alerts` channel whenever
  any ArgoCD Application goes Degraded or OutOfSync
- Message includes: app name, environment, status, and ArgoCD UI link

## Real Scenario — How PR Diff Would Catch a Mistake

**Scenario:** A developer accidentally changes the NetworkPolicy
to allow ALL egress traffic instead of only DNS and the database.

Without the PR diff workflow, this would be merged and deployed
silently — opening a serious security hole where tenant pods could
reach any external service.

**With the PR diff workflow:**
- The diff comment on the PR would clearly show the NetworkPolicy
  changed from restricted egress to allow-all
- The reviewer would immediately spot the mistake
- The PR would be rejected before it ever reaches production

This is exactly the kind of subtle but critical infra mistake that
is invisible in a normal code review but obvious in a resource diff.

## Kustomize Output
See `kustomize-output.txt` for the full rendered manifest output.
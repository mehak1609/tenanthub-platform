# Task 3 — Infra Change Visibility

## What I Was Trying to Solve
The team was merging infrastructure PRs without knowing what Kubernetes 
resources would actually change. A small YAML edit could accidentally 
delete a NetworkPolicy or change a Role — and nobody would notice until 
something broke in production.

There was also no alerting when ArgoCD deployments went wrong, so 
failures were discovered late.

## What I Built

### PR Diff Workflow
I wrote a GitHub Actions workflow that runs on every PR to the infra repo.
It builds the Kustomize output for both the PR branch and main, diffs 
the two outputs, and posts the result as a comment directly on the PR.

This means before anyone merges, they can see exactly which Kubernetes 
resources will be added, changed, or removed — right in the PR itself.

### ArgoCD Slack Alert
I configured ArgoCD notifications to send a Slack message to 
#devops-alerts whenever any Application transitions to Degraded or 
OutOfSync. The message includes the app name, environment, and a 
direct link to the ArgoCD UI so the team can investigate immediately.

## Real Scenario — How This Would Have Caught a Mistake
Imagine a developer is updating the NetworkPolicy for acme-corp and 
accidentally removes the egress restrictions, allowing all outbound 
traffic. In a normal code review, this is easy to miss — YAML diffs 
are hard to read.

With the PR diff workflow, the comment on the PR would clearly show 
the NetworkPolicy changed from restricted egress to allow-all. The 
reviewer would spot it immediately and reject the PR before it ever 
reaches production. This kind of subtle but critical security mistake 
is exactly what this workflow is designed to catch.
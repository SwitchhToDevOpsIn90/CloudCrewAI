# Playbook: Cloud Cost Optimization

## WHY

Cloud costs grow silently. Unused resources, oversized instances, and forgotten test environments accumulate charges for months before anyone notices, and clients specifically value this work because it ties technical action directly to a number on their bill. Some costs are even more dangerous than gradual creep — automatic, unannounced jumps triggered by inaction rather than a deliberate provisioning choice.

## WHAT This Playbook Delivers

An automated cost anomaly detection system, a rightsizing recommendation report based on actual usage data, scheduled shutdown automation for non-production resources, and awareness of known automatic-escalation traps specific to individual AWS services — with a documented savings percentage the client can see concretely.

## Prerequisites

AWS Cost Explorer enabled on the account. Read access to billing data and resource utilization metrics. A clear understanding of which resources are production (never touched by shutdown automation) versus non-production (safe to schedule).

## Steps

1. Pull baseline cost data for the trailing 30 to 90 days before making any changes, so improvement is measurable against a real number, not an estimate.

2. Identify genuinely idle or oversized resources using actual CloudWatch utilization metrics, never assumptions. A t3.large sitting at 3 percent CPU for a month is a rightsizing candidate; the same instance at 60 percent is not.

3. Tag every resource clearly as production or non-production before building any automation that acts on that distinction.

4. Build a scheduled Lambda function that stops non-production resources outside business hours and starts them again each morning, using the tags from step 3 to decide what to touch.

5. Set a Cost Anomaly Detection alert in AWS, or build an equivalent Lambda comparing daily spend against a rolling average, alerting when spend spikes unexpectedly.

6. Generate a rightsizing report showing specific instances, their actual utilization, and a recommended smaller size, without automatically resizing anything without review.

7. Document the actual before and after cost comparison once changes have run for at least one full billing cycle, since this concrete number is the most valuable deliverable to a client.

8. Before recommending or provisioning any AWS service, specifically check for known automatic cost-escalation traps unique to that service, not just its advertised baseline price. Some AWS services jump to a significantly higher cost automatically, triggered by inaction rather than a deliberate choice.

## Known Automatic-Escalation Traps (verify current pricing before relying on these, as they can change)

IAM Identity Center: enabling this feature can force an entire account off a Free Tier or credits-based plan immediately, regardless of the feature's own advertised cost — the trap is at the account level, not the feature's line-item price.

Amazon EKS extended version support: a cluster that falls behind on Kubernetes version support automatically jumps from the standard control plane fee to a significantly higher extended-support fee — confirmed as a 6x increase (from roughly $73/month to roughly $438/month as of 2026 — verify current figures before citing) — without any active choice by the account owner, triggered purely by version staleness.

## Guardrail Check

Never automatically stop or resize a resource tagged as production. Never apply a rightsizing recommendation without human review, since utilization data can miss context like planned upcoming load. Confirm the client's billing alarm exists before this playbook even begins, per the general server monitoring playbook. Before recommending any managed service with a control plane or platform fee (EKS being the clearest example), explicitly check for automatic-escalation conditions specific to that service, not just its baseline advertised price.

## Reference Implementation

See AWS Cost Explorer and AWS Compute Optimizer documentation for the underlying data sources this playbook relies on. See github.com/SwitchhToDevOpsIn90/devops-journey, Session 23, for the real IAM Identity Center account-level trap discovered and avoided. See Session 28 for the EKS extended-support 6x price jump discovered during a real ECS-vs-EKS architecture decision, verified via current search rather than relied on from memory, directly informing a real, documented decision to use ECS with Fargate for a small single-service application while still fully learning EKS later in the curriculum for its genuine industry relevance.
